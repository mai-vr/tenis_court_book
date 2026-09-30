# Tenis Court Book

Aplicación Rails para administrar clubes de tenis, canchas, horarios y reservas. Incluye un back-office web y una API JSON versionada.

## Requisitos

- Ruby 3.4.10 (versión indicada en `.ruby-version`). En Windows se recomienda RubyInstaller con Devkit.
- Bundler.
- SQLite 3, utilizado por defecto en desarrollo y test.

## Instalación y ejecución

Desde la raíz del proyecto, en PowerShell o una terminal compatible:

```sh
bundle install
bundle exec rails db:prepare
bundle exec rails server
```

La aplicación queda disponible en `http://localhost:3000`. La raíz abre el back-office. Para detener el servidor, presiona `Ctrl+C`.

## Base de datos

La configuración de desarrollo usa SQLite en `storage/development.sqlite3`. `bundle exec rails db:prepare` crea la base si no existe y aplica el esquema/migraciones pendientes. El entorno de test usa `storage/test.sqlite3`.

El comando anterior no carga datos de ejemplo. El archivo `db/seeds.rb` todavía contiene datos iniciales incompatibles con las validaciones y roles actuales, por lo que `db:seed` puede fallar; no es necesario para iniciar la aplicación.

Para preparar un primer usuario superadministrador local, abre la consola con `bundle exec rails console` y ejecuta, cambiando los datos por los tuyos:

```ruby
User.create!(
	first_name: "Admin",
	last_name: "Local",
	email_address: "admin@gmail.com",
	password: "pepe123",
	password_confirmation: "pepe123",
	role: :superadmin
)
```

Luego inicia sesión desde `http://localhost:3000/session/new`. El back-office permite gestionar clubes, canchas, horarios, reservas y pagos. Un `club_admin` queda asociado a un club; el `superadmin` puede gestionar clubes y administrar usuarios.


## API principal

La API responde JSON y su prefijo es `/api/v1`.

| `POST` | `/api/v1/users` | Registra un usuario. Recibe `first_name`, `last_name`, `email_address`, `password` y `password_confirmation`; devuelve un token JWT. | Público |
| `POST` | `/api/v1/login` | Inicia sesión. Recibe `email_address` (o `email`) y `password`; devuelve un token JWT. | Público |
| `GET` | `/api/v1/clubs` | Lista clubes e incluye ubicación y URL del logo. | Público |
| `GET` | `/api/v1/clubs/:id` | Devuelve un club, su ubicación y sus horarios. | Público |
| `GET` | `/api/v1/clubs/:club_id/courts` | Lista las canchas de un club. | Público |
| `GET` | `/api/v1/clubs/:club_id/courts/:id` | Devuelve una cancha de ese club. | Público |
| `POST` | `/api/v1/clubs/:club_id/reservations` | Crea una reserva y su pago asociado. Requiere un token JWT. | Autenticado |

Para las solicitudes autenticadas, enviar el token en la cabecera `Authorization: Bearer <token>`. La reserva recibe un objeto `reservation` con `current_date`, `start_time`, `end_time` y `court_id`; opcionalmente acepta `payment_method`.

## Modelo de datos

- **User**: usuarios cliente, superadministradores o administradores de club. Un administrador de club pertenece a un club.
- **Club**: club con ubicación, datos de contacto, logo, canchas y horarios.
- **Location**: dirección asociada a un club.
- **Court**: cancha de un club, con superficie, precio por hora, condición cubierta y estado.
- **Schedule**: días y franjas horarias de atención de un club.
- **Reservation**: reserva de una cancha hecha por un usuario, con fecha, horario y estado. Se valida disponibilidad, horario del club y solapamientos; las reservas tienen una duración de una hora.
- **Payment**: pago asociado a una reserva, con método, importe y estado.

## Pruebas

```sh
bundle exec rails test
```