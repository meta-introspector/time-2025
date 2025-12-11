#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct BoundingBox {
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
}

impl BoundingBox {
    pub fn new(x: f32, y: f32, width: f32, height: f32) -> Self {
        BoundingBox { x, y, width, height }
    }

    pub fn area(&self) -> f32 {
        self.width * self.height
    }

    /// Checks if another bounding box is fully contained within this one.
    pub fn contains(&self, other: &BoundingBox) -> bool {
        other.x >= self.x &&
        other.y >= self.y &&
        (other.x + other.width) <= (self.x + self.width) &&
        (other.y + other.height) <= (self.y + self.height)
    }

    /// Checks if two bounding boxes overlap.
    pub fn overlaps(&self, other: &BoundingBox) -> bool {
        self.x < (other.x + other.width) &&
        (self.x + self.width) > other.x &&
        self.y < (other.y + other.height) &&
        (self.y + self.height) > other.y
    }
}
