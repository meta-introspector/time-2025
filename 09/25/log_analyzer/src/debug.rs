use std::sync::atomic::{AtomicUsize, Ordering};

pub struct StepTracer {
    step_counter: AtomicUsize,
    max_steps: Option<usize>,
}

impl StepTracer {
    pub fn new(max_steps: Option<usize>) -> Self {
        Self {
            step_counter: AtomicUsize::new(0),
            max_steps,
        }
    }

    pub fn step(&self, message: &str) {
        let current_step = self.step_counter.fetch_add(1, Ordering::SeqCst);
        println!("[Step {}]: {}", current_step, message);

        if let Some(max_steps) = self.max_steps {
            if current_step >= max_steps {
                println!("Max steps reached. Exiting.");
                std::process::exit(0);
            }
        }
    }
}
