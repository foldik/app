#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use]
extern crate rocket;
#[macro_use]
extern crate serde_derive;

use rocket_contrib::helmet::SpaceHelmet;
use rocket_contrib::serve::StaticFiles;
use rocket_contrib::templates::Template;
use std::collections::HashMap;

mod api;

#[get("/")]
#[catch(404)]
fn root() -> Template {
    let context = HashMap::<String, String>::new();
    Template::render("index", context)
}

pub fn run() {
    rocket::ignite()
        .mount("/api", routes!(api::session::get_session))
        .mount("/", routes![root])
        .mount("/static", StaticFiles::from("dist"))
        .register(catchers![root])
        .attach(SpaceHelmet::default())
        .attach(Template::fairing())
        .launch();
}
