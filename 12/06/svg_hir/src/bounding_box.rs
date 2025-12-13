#[derive(Debug, Clone, PartialEq, Default, serde::Serialize, serde::Deserialize)]
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

    pub fn contains_point(&self, px: f32, py: f32) -> bool {
        px >= self.x && px <= (self.x + self.width) &&
        py >= self.y && py <= (self.y + self.height)
    }

    /// Checks if two bounding boxes overlap.
    pub fn overlaps(&self, other: &BoundingBox) -> bool {
        self.x < (other.x + other.width) &&
        (self.x + self.width) > other.x &&
        self.y < (other.y + other.height) &&
        (self.y + self.height) > other.y
    }

    pub fn union(&self, other: &BoundingBox) -> BoundingBox {
        if self.width == 0.0 && self.height == 0.0 {
            return other.clone();
        }
        if other.width == 0.0 && other.height == 0.0 {
            return self.clone();
        }

        let x = self.x.min(other.x);
        let y = self.y.min(other.y);

        let x_max = (self.x + self.width).max(other.x + other.width);
        let y_max = (self.y + self.height).max(other.y + other.height);

        BoundingBox {
            x,
            y,
            width: x_max - x,
            height: y_max - y,
        }
    }
}