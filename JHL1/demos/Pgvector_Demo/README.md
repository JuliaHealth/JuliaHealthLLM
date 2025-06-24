# Pgvector Demo on a sample sentences data

## Setup for Windows

Install PostgreSQL from the [official website](https://www.postgresql.org/download/).

Ensure C++ support in Visual Studio is installed, and run:

```cmd
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
```

Note: The exact path will vary depending on your Visual Studio version and edition

Then use `nmake` to build:

```cmd
set "PGROOT=C:\Program Files\PostgreSQL\16"
cd %TEMP%
git clone --branch v0.8.0 https://github.com/pgvector/pgvector.git
cd pgvector
nmake /F Makefile.win
nmake /F Makefile.win install
```

After installation, open the PostgreSQL command line or pgAdmin and run:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

create a new database named pgvectordemo in pgsql

run the code in main.jl