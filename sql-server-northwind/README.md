Building docker image
```
docker build --platform=linux/x86_64 -t sql-server .
```

Run in interactive session
```
docker run -it --platform=linux/x86_64 --rm -p 1433:1433 sql-server
```