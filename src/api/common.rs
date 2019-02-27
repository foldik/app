#[derive(Serialize, Deserialize)]
pub struct Data<T> {
    pub data: T,
}

#[derive(FromForm)]
pub struct Pageable {
    pub page: u32,
    pub limit: u32,
}

#[derive(Serialize, Deserialize)]
pub struct PaginatedList<T> {
    pub page: u32,
    pub limit: u32,
    pub max: u32,
    pub data: Vec<T>,
}
