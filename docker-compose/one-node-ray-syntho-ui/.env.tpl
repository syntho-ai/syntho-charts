LICENSE_KEY={{ LICENSE_KEY }}

ADMIN_USERNAME={{ ADMIN_USERNAME }}
ADMIN_PASSWORD={{ ADMIN_PASSWORD }}
ADMIN_EMAIL={{ ADMIN_EMAIL }}

RAY_IMAGE={{ RAY_IMAGE_IMG_REPO }}:{{ RAY_IMAGE_IMG_TAG }}
CORE_IMAGE={{ SYNTHO_UI_CORE_IMG_REPO }}:{{ SYNTHO_UI_CORE_IMG_VER }}
BACKEND_IMAGE={{ SYNTHO_UI_BACKEND_IMG_REPO }}:{{ SYNTHO_UI_BACKEND_IMG_VER }}
FRONTEND_IMAGE={{ SYNTHO_UI_FRONTEND_IMG_REPO }}:{{ SYNTHO_UI_FRONTEND_IMG_VER }}

FRONTEND_HOST=localhost:3000
FRONTEND_DOMAIN=localhost

# If another port needs to be exposed for the backend API and Frontend, change that here
BACKEND_PORT=8000
FRONTEND_PORT=3000

# AI Cluster machine limits (Ray)
RAY_CPUS={{ RAY_CPUS }}
RAY_MEMORY={{ RAY_MEMORY }}

# If TLS is used, set protocol to https and secured_cookies to True
FRONTEND_PROTOCOL=http
SECURED_COOKIES="False"

CORE_DATABASE_HOST=postgres
CORE_DATABASE_USER=syntho
CORE_DATABASE_PASSWORD=!2ImY6&A!*i3
CORE_DATABASE_NAME=syntho-core
CORE_SECRET_KEY=Myyxngwf-NL04CgyD6WvcyMD09rMkN_fk3q0Bga54ME=
CORE_BROKER_URL=redis://redis:6379/0
CORE_RESULT_BACKEND=redis://redis:6379/0
CORE_RAY_ADDRESS=head
CORE_PORT=8080
CORE_REDIS_HOST=redis
CORE_REDIS_PORT=6379

BACKEND_SECRET_KEY="66n6ldql(b2g0jmop(gr)"
BACKEND_REDIS_HOST=redis
BACKEND_REDIS_PORT=6379
BACKEND_REDIS_DB_INDEX=1
BACKEND_DB_HOST=postgres
BACKEND_DB_NAME=syntho-backend
BACKEND_DB_USER=syntho
BACKEND_DB_PASSWORD=!2ImY6&A!*i3
BACKEND_DB_PORT=5432
BACKEND_DATA_ACCESS=True

# Debug variables, only change if you know what you're doing
# If CORE_APP_ENV is set to prod, CORE_RAY_ADDRESS cannot be empty
# Set to dev for testing purposes
CORE_APP_ENV=prod
