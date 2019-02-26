#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;
extern crate rocket_contrib;

use rocket_contrib::serve::StaticFiles;
use rocket_contrib::helmet::SpaceHelmet;
use rocket_contrib::templates::{Template};
use std::collections::HashMap;

#[get("/")]
#[catch(404)]
fn root() -> Template {
    let context = HashMap::<String, String>::new();
    Template::render("index", context)
}

pub fn run() {
    rocket::ignite()
        .mount("/static", StaticFiles::from("dist"))
        .mount("/", routes![root])
        .register(catchers![root])
        .attach(SpaceHelmet::default())
        .attach(Template::fairing())
        .launch();
}