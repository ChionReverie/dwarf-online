use actix_web::middleware::Logger;
use actix_web::{App, HttpServer, get};
use actix_web::web::Json;
use utoipa_actix_web::AppExt;
use utoipa_swagger_ui::SwaggerUi;

#[actix_web::main]
async fn main() -> std::io::Result<()> {

    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    HttpServer::new(|| {
            let (app, api) = App::new()
                .into_utoipa_app()
                .map(|app| app.wrap(Logger::default()))
                .service(get_health)
                .service(get_index)
                .split_for_parts();
            app.service(SwaggerUi::new("/swagger-ui/{_:.*}").url("/api-docs/openapi.json", api))
        }
    )
    .bind(("127.0.0.1", 8080))?
    .bind(("172.22.74.1", 8080))?
    .run()
    .await
}

#[derive(utoipa::ToSchema, serde::Serialize)]
struct Health {
    message: String,
}

#[utoipa::path(
    responses((status = 200, body = str))
)]
#[get("/health")]
async fn get_health() -> Json<Health> {
    Json(Health { message: "Healthy!".to_string() })
}

#[utoipa::path(
    responses((status = 200, body = str))
)]
#[get("/")]
async fn get_index() -> &'static str {
    "Hello world!"
}