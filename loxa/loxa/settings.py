import os

from pathlib import Path
from datetime import timedelta
from corsheaders.defaults import default_headers

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = os.getenv("DJANGO_SECRET_KEY", "insecure")
DEBUG = os.getenv("DJANGO_DEBUG", "0") == "1"
# DEBUG = os.getenv("DEBUG","").lower() in ("1","true","yes")

ALLOWED_HOSTS = os.getenv("DJANGO_ALLOWED_HOSTS", "*").split(",")

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")




# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    "rest_framework",
    "django_filters",
    "rest_framework_simplejwt.token_blacklist",
    "rest_framework_simplejwt",

    "api",
    "orgs",
    "accounts",
    "authphone",
    "django_prometheus",

    "social_django",
    "corsheaders",

    "drf_yasg",
]

MIDDLEWARE = [

    "django_prometheus.middleware.PrometheusBeforeMiddleware",

    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    
    "django_prometheus.middleware.PrometheusAfterMiddleware",
    "loxa.middleware.TenantResolver",

    "orgs.middleware.CurrentOrgMiddleware",
]

# MIDDLEWARE.insert(0, "loxa.middleware.TenantResolver")




ROOT_URLCONF = 'loxa.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'loxa.wsgi.application'


# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

DATABASES = {
    # 'default': {
    #     'ENGINE': 'django.db.backends.sqlite3',
    #     'NAME': BASE_DIR / 'db.sqlite3',
    # }

    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.getenv("POSTGRES_DB", "loxa_db"),
        "USER": os.getenv("POSTGRES_USER", "loxa_user"),
        "PASSWORD": os.getenv("POSTGRES_PASSWORD", "loxa@loxa"),
        "HOST": os.getenv("POSTGRES_HOST", "localhost"),
        "PORT": os.getenv("POSTGRES_PORT", "5432"),
        "OPTIONS": {"connect_timeout": 5},
    }
}


# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATIC_URL = "/static/"
STATIC_ROOT = "/data/static"          # <- docker volume mount နဲ့တူရမယ်
STATICFILES_DIRS = [
    BASE_DIR / "static",              # project-level assets (optional)
    BASE_DIR / "loxa" / "static",     # app-level assets (if you have)
    # BASE_DIR / "api" / "static",      # app-level assets (if you have)
]


# Media (our own storage)
MEDIA_URL = "/media/"
MEDIA_ROOT = "/data/media"

# Small helper used by views to build safe paths
STORAGES = {
    "staticfiles": {"BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage"},
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
}


def build_media_path(*parts):
    # prevent path traversal
    safe = [str(p).replace("..", "").lstrip("/") for p in parts]
    return os.path.join(MEDIA_ROOT, *safe)


# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'




AUTH_USER_MODEL = "accounts.User"




REST_FRAMEWORK = {

    "DEFAULT_RENDERER_CLASSES": [
        "rest_framework.renderers.JSONRenderer",
        
        *(("rest_framework.renderers.BrowsableAPIRenderer",) if DEBUG else ()),
    ],
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework.authentication.SessionAuthentication",
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    "DEFAULT_FILTER_BACKENDS": [
        "django_filters.rest_framework.DjangoFilterBackend",
    ],
    "DEFAULT_THROTTLE_CLASSES": (
        "rest_framework.throttling.AnonRateThrottle",
        "rest_framework.throttling.UserRateThrottle",
        "rest_framework.throttling.ScopedRateThrottle",
    ),
    "DEFAULT_THROTTLE_RATES": {
        "anon": "30/min",
        "user": "120/min",
        "session_join": "60/min",
    },

    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 20,
}



SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=60),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=14),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
    "AUTH_HEADER_TYPES": ("Bearer",),
}


USE_REDIS_CACHE = True
if USE_REDIS_CACHE:
    CACHES = {
        "default": {
            "BACKEND": "django_redis.cache.RedisCache",
            "LOCATION": "redis://redis:6379/0",
            "OPTIONS": {"CLIENT_CLASS": "django_redis.client.DefaultClient"},
            "KEY_PREFIX": "loxa",
        }
    }
else:
    # Option B: Database cache (no extra dependency)
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.db.DatabaseCache",
            "LOCATION": "loxa_cache_table",
        }
    }


# Channels / ASGI (optional)
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": [("redis", 6379)],
        },
    },
}

# Celery (optional)
CELERY_BROKER_URL = "redis://redis:6379/0"

AUTHENTICATION_BACKENDS = (
    "social_core.backends.google.GoogleOAuth2",   # add providers you need
    "django.contrib.auth.backends.ModelBackend",
)



# OAuth client keys via env
SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = os.getenv("GOOGLE_CLIENT_ID", "")
SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = os.getenv("GOOGLE_CLIENT_SECRET", "")
SOCIAL_AUTH_REDIRECT_IS_HTTPS = False  # dev only
SOCIAL_AUTH_LOGIN_REDIRECT_URL = "/"
SOCIAL_AUTH_LOGIN_ERROR_URL = "/"

# After social auth succeeds, we mint JWT:
SOCIAL_AUTH_PIPELINE = (
    "social_core.pipeline.social_auth.social_details",
    "social_core.pipeline.social_auth.social_uid",
    "social_core.pipeline.social_auth.auth_allowed",
    "social_core.pipeline.social_auth.social_user",
    "social_core.pipeline.user.get_username",
    "social_core.pipeline.user.create_user",
    "social_core.pipeline.social_auth.associate_user",
    "social_core.pipeline.social_auth.load_extra_data",
    "social_core.pipeline.user.user_details",
)


SWAGGER_SETTINGS = {
    "USE_SESSION_AUTH": False,  # we'll use Bearer JWT
    "SECURITY_DEFINITIONS": {
        "Bearer": {
            "type": "apiKey",
            "name": "Authorization",
            "in": "header",
            "description": 'Paste **Bearer &lt;your_JWT&gt;** here. Example: `Bearer eyJ0eXAiOiJK...`',
        },
    },
}


# if DEBUG:
#     REST_FRAMEWORK["DEFAULT_RENDERER_CLASSES"] = [
#         "rest_framework.renderers.JSONRenderer",
#         "rest_framework.renderers.BrowsableAPIRenderer",
#     ]
# else:
#     REST_FRAMEWORK["DEFAULT_RENDERER_CLASSES"] = [
#         "rest_framework.renderers.JSONRenderer",
#     ]



LOGIN_REDIRECT_URL = "api/"
LOGOUT_REDIRECT_URL = "/"

SESSION_ENGINE = "django.contrib.sessions.backends.db"

# Cache ကို LocMem (redis မရှိလဲ OK)
if DEBUG:
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "loxa-dev-cache",
        }
    }


LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {"console": {"class": "logging.StreamHandler"}},
    "root": {"handlers": ["console"], "level": "INFO"},
    "loggers": {
        "django.request": {"handlers": ["console"], "level": "ERROR", "propagate": False},
        "django.security": {"handlers": ["console"], "level": "ERROR", "propagate": False},
    },
}

AUTHENTICATION_BACKENDS = [
    "django.contrib.auth.backends.ModelBackend",   # admin login အတွက် လိုတာ
    "authphone.backends.PhoneBackend",
]



TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID", "")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "")
TWILIO_FROM_NUMBER = os.getenv("TWILIO_FROM_NUMBER", "")

OTP_EXP_MINUTES = int(os.getenv("OTP_EXP_MINUTES", "5"))
OTP_RESEND_COOLDOWN_SEC = int(os.getenv("OTP_RESEND_COOLDOWN_SEC", "60"))
OTP_MAX_PER_HOUR = int(os.getenv("OTP_MAX_PER_HOUR", "5"))




AGORA_APP_ID = os.getenv("AGORA_APP_ID", "b208ace79f984b2392645c9408edde36")
AGORA_APP_CERT = os.getenv("AGORA_APP_CERT", "1a13e2c464c4fd2b98ad0154f01577a")
AGORA_TOKEN_TTL_SEC = int(os.getenv("AGORA_TOKEN_TTL_SEC", "7200"))



import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN","https://08d88d0c4292dce31c730ccdc44aadad@o4509988971610112.ingest.de.sentry.io/4509988973445200"),
    integrations=[DjangoIntegration()],
    traces_sample_rate=0.2,  # APM
    send_default_pii=False,
)


CELERY_BROKER_URL = os.getenv("REDIS_URL","redis://redis:6379/0")
CELERY_RESULT_BACKEND = CELERY_BROKER_URL


import sentry_sdk

sentry_sdk.init(
    dsn="",
    # Add data like request headers and IP for users,
    # see https://docs.sentry.io/platforms/python/data-management/data-collected/ for more info
    send_default_pii=True,
)

# settings.py (dev)
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = True
# CORS_ALLOWED_ORIGINS = [
#     "http://localhost:5173",   # Vite
#     "http://localhost:3000",   # React
#     "http://localhost:38655",  # Flutter web dev server
#     "http://127.0.0.1:33421",
# ]


from corsheaders.defaults import default_methods
from corsheaders.defaults import default_headers
CORS_ALLOW_METHODS = list(default_methods)
CORS_ALLOW_HEADERS = list(default_headers) + [
    "accept", "accept-encoding", "authorization", "content-type",
    "origin", "x-csrftoken", "x-org-id", "user-agent",
]
# OPTIONS (preflight) အဆင်ပြေစေဖို့
CORS_ALLOW_METHODS = ["GET","POST","PUT","PATCH","DELETE","OPTIONS"]


AGORA_APP_ID = os.getenv("AGORA_APP_ID", "ddf12d43c7f446aaaad63571b86f348d")
AGORA_APP_CERT = os.getenv("AGORA_APP_CERT", "21509bc3f9eb4753857c83389329da24")
AGORA_TOKEN_TTL_SEC = int(os.getenv("AGORA_TOKEN_TTL_SEC", "3600"))