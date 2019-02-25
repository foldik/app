#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;
extern crate rocket_contrib;

use rocket_contrib::serve::StaticFiles;
use rocket_contrib::helmet::SpaceHelmet;
use rocket_contrib::templates::{Template};
use std::collections::HashMap;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[get("/2")]
fn index2() -> &'static str {
    "Hello, world 2!"
}

#[get("/")]
fn root() -> Template {
    let context = HashMap::<String, String>::new();
    Template::render("index", context)
}

fn main() {
    rocket::ignite()
        .attach(SpaceHelmet::default())
        .mount("/api", routes![index, index2])
        .mount("/static", StaticFiles::from("dist"))
        .mount("/", routes![root])
        .attach(Template::fairing())
        .launch();
}