pub mod input;
pub mod orient;
pub mod decide;
pub mod act;
pub mod reflect;

use svg_parser_tool::processors::ExtractedData;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let (root_path, db_type) = input::get_args()?;
    let (cache, all_file_entries) = orient::orient(&root_path, &db_type)?;

    let extracted_data = match decide::decide(&cache, &root_path, &all_file_entries)? {
        Some(data) => data,
        None => {
            let mut data = ExtractedData::new();
            act::act(cache.as_ref(), &all_file_entries, &mut data)?;
            // Cache the new data
            let master_cache_key = svg_parser_tool::utils::calculate_master_cache_key(&root_path, &all_file_entries);
            let serialized_data = serde_json::to_vec(&data)?;
            cache.put(&master_cache_key, &serialized_data)?;
            data
        }
    };

    reflect::reflect(&extracted_data);

    Ok(())
}
