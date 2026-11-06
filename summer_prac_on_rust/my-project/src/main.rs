use structopt::StructOpt;
use tokio_postgres::{NoTls, Error};
use tokio::sync::Mutex; // Используем tokio::sync::Mutex
use std::sync::Arc;

#[derive(StructOpt, Debug)]
#[structopt(name = "database-cli", about = "CLI для взаимодействия с базой данных PostgreSQL")]
struct Cli {
    #[structopt(subcommand)]
    command: Command,
}

#[derive(StructOpt, Debug)]
enum Command {
    /// Создание таблицы с произвольными столбцами
    CreateTable {
        table_name: String,
        columns: Vec<String>, // Пример использования: name TEXT age INT
    },

    /// Добавление записи в произвольную таблицу
    InsertRow {
        table_name: String,
        values: Vec<String>, // Пример использования: 'John' 30
    },

    /// Обновление записи в таблице
    UpdateRow {
        table_name: String,
        set_clause: String, // Пример использования: "age = 31"
        condition: String,  // Пример использования: "name = 'John'"
    },

    /// Удаление записи из таблицы
    DeleteRow {
        table_name: String,
        condition: String,  // Пример использования: "name = 'John'"
    },

    /// Чтение всех записей из таблицы
    SelectAllRows {
        table_name: String,
    },

    /// Добавление нового столбца в таблицу
    AddColumn {
        table_name: String,
        column_definition: String, // Пример использования: "email TEXT"
    },

    /// Удаление столбца из таблицы
    DropColumn {
        table_name: String,
        column_name: String,
    },
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    // Запрашиваем данные для подключения один раз при запуске
    let mut host = String::new();
    let mut port = String::new();
    let mut user = String::new();
    let mut password = String::new();
    let mut dbname = String::new();

    println!("Введите хост базы данных (например, localhost): ");
    std::io::stdin().read_line(&mut host).expect("Не удалось прочитать хост");
    
    println!("Введите порт базы данных (например, 5432): ");
    std::io::stdin().read_line(&mut port).expect("Не удалось прочитать порт");
    
    println!("Введите имя пользователя: ");
    std::io::stdin().read_line(&mut user).expect("Не удалось прочитать имя пользователя");
    
    println!("Введите пароль: ");
    std::io::stdin().read_line(&mut password).expect("Не удалось прочитать пароль");
    
    println!("Введите название базы данных: ");
    std::io::stdin().read_line(&mut dbname).expect("Не удалось прочитать название базы данных");

    // Очищаем строки от пробельных символов (новой строки в конце)
    let host = host.trim();
    let port = port.trim();
    let user = user.trim();
    let password = password.trim();
    let dbname = dbname.trim();

    // Формируем строку подключения к базе данных
    let connection_str = format!(
        "host={} port={} user={} password={} dbname={}",
        host, port, user, password, dbname
    );

    // Подключение к базе данных PostgreSQL
    println!("Попытка подключения к базе данных на {}...", host);
    let (client, connection) = tokio_postgres::connect(&connection_str, NoTls).await
        .map_err(|e| {
            eprintln!("Ошибка подключения: {}", e);
            std::process::exit(1);
        })?;
    println!("Подключение успешно установлено.");

    // Оборачиваем client в Arc<Mutex<_>>
    let client = Arc::new(Mutex::new(client));

    // Устанавливаем кодировку в отдельном потоке
    {
        let client = Arc::clone(&client);
        tokio::spawn(async move {
            let client = client.lock().await; // Используем await здесь
            if let Err(e) = client.execute("SET client_encoding TO 'UTF8';", &[]).await {
                eprintln!("Ошибка установки кодировки: {}", e);
            }
        });
    }

    // Обработка соединения в отдельном потоке
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("Ошибка соединения: {}", e);
        }
    });

    // Получение аргументов командной строки
    let args = Cli::from_args();

    // Обработка команд
    match args.command {
        Command::CreateTable { table_name, columns } => {
            let client = client.lock().await; 
            let columns_str = columns.join(", ");
            let query = format!("CREATE TABLE IF NOT EXISTS {} ({})", table_name, columns_str);
            
            match client.execute(&query, &[]).await {
                Ok(_) => {
                    println!("Таблица {} создана с колонками: {}", table_name, columns_str);
                }
                Err(e) => {
                    eprintln!("Ошибка при создании таблицы: {}", e);
                }
            }
        }
    
        Command::InsertRow { table_name, values } => {
            let client = client.lock().await; 
            let values_placeholder: Vec<String> = (1..=values.len()).map(|i| format!("${}", i)).collect();
            let query = format!(
                "INSERT INTO {} VALUES ({})",
                table_name,
                values_placeholder.join(", ")
            );
            let values_refs: Vec<&(dyn tokio_postgres::types::ToSql + Sync)> = values.iter().map(|v| v as _).collect();
            
            match client.execute(&query, &values_refs[..]).await {
                Ok(_) => {
                    println!("Запись добавлена в таблицу {}", table_name);
                }
                Err(e) => {
                    eprintln!("Ошибка при добавлении записи: {}", e);
                }
            }
        }
    
        Command::UpdateRow { table_name, set_clause, condition } => {
            let client = client.lock().await; 
            let query = format!("UPDATE {} SET {} WHERE {}", table_name, set_clause, condition);
            
            match client.execute(&query, &[]).await {
                Ok(_) => {
                    println!("Запись обновлена в таблице {}", table_name);
                }
                Err(e) => {
                    eprintln!("Ошибка при обновлении записи: {}", e);
                }
            }
        }
    
        Command::DeleteRow { table_name, condition } => {
            let client = client.lock().await; 
            let query = format!("DELETE FROM {} WHERE {}", table_name, condition);
            
            match client.execute(&query, &[]).await {
                Ok(_) => {
                    println!("Запись удалена из таблицы {}", table_name);
                }
                Err(e) => {
                    eprintln!("Ошибка при удалении записи: {}", e);
                }
            }
        }
    
        Command::SelectAllRows { table_name } => {
            let client = client.lock().await; 
            match client.query(&format!("SELECT * FROM {}", table_name), &[]).await {
                Ok(rows) => {
                    for row in &rows {
                        for (i, col) in row.columns().iter().enumerate() {
                            let value: &str = row.get(i);
                            print!("{}: {} ", col.name(), value);
                        }
                        println!();
                    }
                }
                Err(e) => {
                    eprintln!("Ошибка при чтении записей: {}", e);
                }
            }
        }
    
        Command::AddColumn { table_name, column_definition } => {
            let client = client.lock().await; 
            let query = format!("ALTER TABLE {} ADD COLUMN {}", table_name, column_definition);
            
            match client.execute(&query, &[]).await {
                Ok(_) => {
                    println!("Столбец {} добавлен в таблицу {}", column_definition, table_name);
                }
                Err(e) => {
                    eprintln!("Ошибка при добавлении столбца: {}", e);
                }
            }
        }
    
        Command::DropColumn { table_name, column_name } => {
            let client = client.lock().await; 
            let query = format!("ALTER TABLE {} DROP COLUMN {}", table_name, column_name);
            
            match client.execute(&query, &[]).await {
                Ok(_) => {
                    println!("Столбец {} удален из таблицы {}", column_name, table_name);
                }
                Err(e) => {
                    eprintln!("Ошибка при удалении столбца: {}", e);
                }
            }
        }
    }

    Ok(())
}

/* Примеры команд:

1. Создание таблицы с произвольными колонками:
   cargo run -- create-table <table_name> <column_name_1> <type_1> <column_name_2> <type_2>
   Пример: cargo run -- create-table my_table name TEXT age INT

2. Вставка строки:
   cargo run -- insert-row <table_name> <value_1> <value_2>
   Пример: cargo run -- insert-row my_table 'John' 30

3. Обновление строки:
   cargo run -- update-row <table_name> "<set_clause>" "<condition>"
   Пример: cargo run -- update-row my_table "age = 31" "name = 'John'"

4. Удаление строки:
   cargo run -- delete-row <table_name> "<condition>"
   Пример: cargo run -- delete-row my_table "name = 'John'"

5. Чтение всех строк:
   cargo run -- select-all-rows <table_name>
   Пример: cargo run -- select-all-rows my_table

6. Добавление столбца:
   cargo run -- add-column <table_name> <column_definition>
   Пример: cargo run -- add-column my_table email TEXT

7. Удаление столбца:
   cargo run -- drop-column <table_name> <column_name>
   Пример: cargo run -- drop-column my_table email
*/
