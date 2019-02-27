use rocket::request::Form;
use rocket_contrib::json::Json;

use crate::api::common::{Pageable, PaginatedList};

#[derive(Serialize, Deserialize)]
pub struct CoursePreview {
    pub id: u32,
    pub title: String,
    pub short_description: String,
    pub last_update: u64,
    pub status: CourseStatus,
}

#[derive(Serialize, Deserialize)]
pub enum CourseStatus {
    Draft,
    Published,
    Public,
}

#[get("/admin/courses?<pageable..>")]
pub fn get_courses(pageable: Form<Pageable>) -> Json<PaginatedList<CoursePreview>> {
    Json(PaginatedList {
        page: pageable.page,
        limit: pageable.limit,
        max: 101,
        data: vec![CoursePreview {
            id: 10,
            title: String::from("Hello World"),
            short_description: String::from("Hello World Short description"),
            last_update: 1551303867,
            status: CourseStatus::Published,
        }],
    })
}
