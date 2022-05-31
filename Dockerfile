FROM python:3.9-alpine as base

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

FROM base as python-deps

# Install pipenv and compilation dependencies
RUN pip install pipenv
RUN apk update
RUN apk add --no-cache --virtual .build-deps gcc musl-dev linux-headers 
RUN apk add postgresql-dev python3-dev


# Install python dependencies in /.venv
COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

FROM base AS runtime

COPY --from=python-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"

# Create and switch to a new user
RUN addgroup -S portfolio_group
RUN adduser -S -D -h /omnitrix portfolio portfolio_group

RUN mkdir /portfolio/app
WORKDIR /portfolio/app

COPY . /portfolio/app

RUN chown -R portfolio:portfolio_group /portfolio/app

USER portfolio

ENTRYPOINT ["python", "manage.py", "runserver"]
CMD ["0.0.0.0:8000"]
