FROM mcr.microsoft.com/mssql/server:2019-latest
USER root
ENV SA_PASSWORD=QWERasdf1234!
ENV ACCEPT_EULA=Y

COPY ./Northwind.bak /var/opt/mssql/data/

RUN /opt/mssql/bin/sqlservr --accept-eula & sleep 15 \
    && /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'QWERasdf1234!' -Q 'RESTORE DATABASE Northwind FROM DISK = "/var/opt/mssql/data/Northwind.bak" WITH MOVE "Northwind" TO "/var/opt/mssql/data/Northwind.mdf", MOVE "Northwind_log" TO "/var/opt/mssql/data/Northwind_log.ldf"'