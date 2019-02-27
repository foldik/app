#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;
#[macro_use]
extern crate serde_derive;

use rocket_contrib::helmet::SpaceHelmet;
use rocket_contrib::json::Json;
use rocket_contrib::serve::StaticFiles;
use rocket_contrib::templates::Template;
use std::collections::HashMap;

#[derive(Serialize)]
pub struct Data<T> {
    pub data: T,
}

#[derive(Serialize)]
pub struct User {
    pub username: String,
    pub first_name: String,
    pub last_name: String,
    pub role: Role,
}

#[derive(Serialize)]
pub enum Role {
    Admin,
    Mentor,
    Student,
}

#[get("/me")]
fn me() -> Json<Data<User>> {
    Json(Data {
        data: User {
            username: String::from("foldik"),
            first_name: String::from("Földi"),
            last_name: String::from("Kristóf"),
            role: Role::Admin,
        },
    })
}

#[get("/")]
#[catch(404)]
fn root() -> Template {
    let context = HashMap::<String, String>::new();
    Template::render("index", context)
}

pub fn run() {
    rocket::ignite()
        .mount("/api", routes!(me))
        .mount("/", routes![root])
        .mount("/static", StaticFiles::from("dist"))
        .register(catchers![root])
        .attach(SpaceHelmet::default())
        .attach(Template::fairing())
        .launch();
}
