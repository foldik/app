use rocket_contrib::json::Json;

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

#[get("/session")]
pub fn get_session() -> Json<Data<User>> {
    Json(Data {
        data: User {
            username: String::from("foldik"),
            first_name: String::from("Földi"),
            last_name: String::from("Kristóf"),
            role: Role::Admin,
        },
    })
}
