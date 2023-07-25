FROM dart:stable
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/domine.dart -o /app/domine
ENTRYPOINT ["/app/domine"]
