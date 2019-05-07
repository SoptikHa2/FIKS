use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::collections::HashSet;

pub struct Network {
    number_of_cities: isize,
    forbidden_cities: Vec<isize>,
    processed_cities: HashSet<isize>,
    city_paths: Vec<Vec<Connection>>,
}

impl Network {
    pub fn new(
        number_of_cities: isize,
        forbidden_cities: Vec<isize>,
        city_paths: Vec<Vec<Connection>>,
    ) -> Network {
        Network {
            number_of_cities,
            forbidden_cities,
            processed_cities: HashSet::new(),
            city_paths,
        }
    }

    pub fn get_result(&mut self) -> isize {
        let mut connection_queue: BinaryHeap<Connection> = BinaryHeap::new();
        let mut maximum_allowed_priority = -1;
        let mut current_priority = 1;

        // First of all, let's process city 0
        {
            let connections = self.city_paths[0];
            for connection in connections {
                connection_queue.push(connection);
            }
            self.processed_cities.insert(0);
        }

        while !connection_queue.is_empty() {
            // Let's take one path and process it.
            let connection_to_current_city = connection_queue.pop().unwrap();

            if self
                .forbidden_cities
                .contains(&connection_to_current_city.target_city)
            {
                maximum_allowed_priority = &connection_to_current_city.priority - 1;
                continue;
            }

            let connections = self.city_paths[connection_to_current_city.target_city as usize];

            for connection in connections {
                let city = &connection.target_city;
                if self.processed_cities.contains(city) {
                    continue;
                } else {
                    connection_queue.push(connection);
                }
            }

            self.processed_cities
                .insert(connection_to_current_city.target_city);
        }

        return maximum_allowed_priority;
    }
}

pub struct Connection {
    originating_city: isize,
    target_city: isize,
    priority: isize,
}

impl Connection {
    pub fn new(originating_city: isize, target_city: isize, priority: isize) -> Connection {
        Connection {
            originating_city,
            target_city,
            priority,
        }
    }
}

impl Ord for Connection {
    fn cmp(&self, other: &Connection) -> Ordering {
        other.priority.cmp(&self.priority)
    }
}
impl PartialOrd for Connection {
    fn partial_cmp(&self, other: &Connection) -> Option<Ordering> {
        Some(other.cmp(self))
    }
}
impl PartialEq for Connection {
    fn eq(&self, other: &Connection) -> bool {
        self.priority == other.priority
    }
}
impl Eq for Connection {}
