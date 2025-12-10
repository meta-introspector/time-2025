// lean_introspector/src/error.rs
#[derive(Debug)]
pub struct GenericError(pub String);

impl std::fmt::Display for GenericError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl std::error::Error for GenericError {}

pub type ThreadSafeError = Box<dyn std::error::Error + Send + 'static>;