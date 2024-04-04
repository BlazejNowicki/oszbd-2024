
# Indeksy,  optymalizator <br>Lab 4

<!-- <style scoped>
 p,li {
    font-size: 12pt;
  }
</style>  -->

<!-- <style scoped>
 pre {
    font-size: 8pt;
  }
</style>  -->


---

**Imię i nazwisko:**

Błażej Nowicki,
Wojciech Jasiński,
Przemysław Węglik,

--- 

Celem ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans), oraz z budową i możliwością wykorzystaniem indeksów.

Swoje odpowiedzi wpisuj w miejsca oznaczone jako:

---
> Wyniki: 

```sql
--  ...
```

---

Ważne/wymagane są komentarze.

Zamieść kod rozwiązania oraz zrzuty ekranu pokazujące wyniki, (dołącz kod rozwiązania w formie tekstowej/źródłowej)

Zwróć uwagę na formatowanie kodu

## Oprogramowanie - co jest potrzebne?

Do wykonania ćwiczenia potrzebne jest następujące oprogramowanie
- MS SQL Server,
- SSMS - SQL Server Management Studio    
- przykładowa baza danych AdventureWorks2017.
    
Oprogramowanie dostępne jest na przygotowanej maszynie wirtualnej


## Przygotowanie  

Uruchom Microsoft SQL Managment Studio.
    
Stwórz swoją bazę danych o nazwie XYZ. 

```sql
create database xyz  
go  
  
use xyz  
go
```

Wykonaj poniższy skrypt, aby przygotować dane:

```sql
select * into [salesorderheader]  
from [adventureworks2017].sales.[salesorderheader]  
go  
  
select * into [salesorderdetail]  
from [adventureworks2017].sales.[salesorderdetail]  
go
```

## Dokumentacja/Literatura

Celem tej części ćwiczenia jest zapoznanie się z planami wykonania zapytań (execution plans) oraz narzędziem do automatycznego generowania indeksów.

Przydatne materiały/dokumentacja. Proszę zapoznać się z dokumentacją:
- [https://docs.microsoft.com/en-us/sql/tools/dta/tutorial-database-engine-tuning-advisor](https://docs.microsoft.com/en-us/sql/tools/dta/tutorial-database-engine-tuning-advisor)
- [https://docs.microsoft.com/en-us/sql/relational-databases/performance/start-and-use-the-database-engine-tuning-advisor](https://docs.microsoft.com/en-us/sql/relational-databases/performance/start-and-use-the-database-engine-tuning-advisor)
- [https://www.simple-talk.com/sql/performance/index-selection-and-the-query-optimizer](https://www.simple-talk.com/sql/performance/index-selection-and-the-query-optimizer)

Ikonki używane w graficznej prezentacji planu zapytania opisane są tutaj:
- [https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference](https://docs.microsoft.com/en-us/sql/relational-databases/showplan-logical-and-physical-operators-reference)






<div style="page-break-after: always;"></div>

# Zadanie 1 - Obserwacja

Wpisz do MSSQL Managment Studio (na razie nie wykonuj tych zapytań):

```sql
-- zapytanie 1  
select *  
from salesorderheader sh  
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid  
where orderdate = '2008-06-01 00:00:00.000'  
go  
  
-- zapytanie 2  
select orderdate, productid, sum(orderqty) as orderqty, 
       sum(unitpricediscount) as unitpricediscount, sum(linetotal)  
from salesorderheader sh  
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid  
group by orderdate, productid  
having sum(orderqty) >= 100  
go  
  
-- zapytanie 3  
select salesordernumber, purchaseordernumber, duedate, shipdate  
from salesorderheader sh  
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid  
where orderdate in ('2008-06-01','2008-06-02', '2008-06-03', '2008-06-04', '2008-06-05')  
go  
  
-- zapytanie 4  
select sh.salesorderid, salesordernumber, purchaseordernumber, duedate, shipdate  
from salesorderheader sh  
inner join salesorderdetail sd on sh.salesorderid = sd.salesorderid  
where carriertrackingnumber in ('ef67-4713-bd', '6c08-4c4c-b8')  
order by sh.salesorderid  
go
```


Włącz dwie opcje: **Include Actual Execution Plan** oraz **Include Live Query Statistics**:



<!-- ![[_img/index1-1.png | 500]] -->


<img src="_img/index1-1.png" alt="image" width="500" height="auto">


Teraz wykonaj poszczególne zapytania (najlepiej każde analizuj oddzielnie). Co można o nich powiedzieć? Co sprawdzają? Jak można je zoptymalizować?  
(Hint: aby wykonać tylko fragment kodu SQL znajdującego się w edytorze, zaznacz go i naciśnij F5)

---
> Wyniki: 

<img src="_img/zad1-1.png">

Zapytanie 1 wykonuje operacje select z klauzulą where na dwóch zjoinowanych tabelach. Zapytanie nie zwraca żadnych wierszy, ponieważ nic nie pasuje do zadanej daty.

Z live query statistics możemy odczytać, że sugerowaną optymalizacją jest stworzenie indeksu na kolumnie `OrderDate` na której wykonujemy operację where.

Z zakładki execution plan możemy odczytać planowane operacje, a z zakładki live query statistics statystyki wykonania tych operacji aktualizowane w czasie rzeczywistym.

W tym przypadku plan składa się jedynie z dwóch table scanów, inner join'a i operacji select.

<img src="_img/zad1-11.png">

Z ciekawości sprawdziliśmy też co się stanie jak się usunie `where` w zapytaniu. Główne operacje jak się można spodziewać pozostają te same jednak zostaną wykonane równolegle.

<img src="_img/zad1-2.png">

Zapytanie zwraca dużo wierszy, stosowane jest wykonanie równoległe.

Sugerowaną modyfikacją jest stworzenie indeksu na kolumnie `salesorderid`co ma na celu przyspieszyć operację join.

Jest to o tyle ciekawe że w poprzednich zapytaniach też występował taki join jednak najbardziej korzystną optymalizają były indeksy przyspieszające where. 

<img src="_img/zad1-3.png">

Zapytanie nie zwraca żadnych wierszy. Sugerowana optymalizacją jest sworznie indeksu na kolumnie orderdate, żeby przyspierszyć operację where.

<img src="_img/zad1-4.png">

Zapytanie zwraca wiersze. W query plan pojawia się etap sortowania wymuszony przez `order by`.

Sugerowana optymalizacją jest sworznie indeksu na kolumnie `carriertrackingnumber`, żeby przyspierszyć operację where.

---





<div style="page-break-after: always;"></div>

# Zadanie 2 - Optymalizacja

Zaznacz wszystkie zapytania, i uruchom je w **Database Engine Tuning Advisor**:

<!-- ![[_img/index1-12.png | 500]] -->

<img src="_img/index1-2.png" alt="image" width="500" height="auto">


Sprawdź zakładkę **Tuning Options**, co tam można skonfigurować?

---
> Wyniki: 

<img src="_img/zad2-1.png">

Możemy wybrać z jakich optymalizacji chcemy skorzystać.
Do wyboru mamy indeksy, widoki z indeksami itp.
Możemy też wybrać czy chcemy dodać partitioning oraz które z istniejących PDS chcemy zostawić w bazie.


---


Użyj **Start Analysis**:

<!-- ![[_img/index1-3.png | 500]] -->

<img src="_img/index1-3.png" alt="image" width="500" height="auto">


Zaobserwuj wyniki w **Recommendations**.

Przejdź do zakładki **Reports**. Sprawdź poszczególne raporty. Główną uwagę zwróć na koszty i ich poprawę:


<!-- ![[_img/index4-1.png | 500]] -->

<img src="_img/index1-4.png" alt="image" width="500" height="auto">


Zapisz poszczególne rekomendacje:

Uruchom zapisany skrypt w Management Studio.

Opisz, dlaczego dane indeksy zostały zaproponowane do zapytań:

---
> Wyniki: 

<img src="_img/zad2-3.png">

SalesOrderID -> join w 1)

CarrierTrackingNumber, SalesOrderID -> przez join dwóch tabel w 4) z where na carrier tracking number

SalesOrderId ProductID -> przez groupby w 2)

SalesOrderId, SalesOrderDetailId -> join w 1)

SalesOrderId, OrderDate -> join w 3)

SalesOrderId -> join w 1)

OrderDate, SalesOrderId -> join w 3)


---


Sprawdź jak zmieniły się Execution Plany. Opisz zmiany:

---
> Wyniki: 

<img src="_img/zad2-21.png">

Table scan zamienia się na clustered index seek. A hash match na nested loops.

<img src="_img/zad2-22.png">

Table scan zamienia się na index scan.

<img src="_img/zad2-23.png">

Table scan zamienia się na clustered index seek. A hash match na nested loops.
<img src="_img/zad2-24.png">
Table scan zamienia się na index seek. A hash match na nested loops.

---


<div style="page-break-after: always;"></div>

# Zadanie 3 - Kontrola "zdrowia" indeksu

## Dokumentacja/Literatura

Celem kolejnego zadania jest zapoznanie się z możliwością administracji i kontroli indeksów.

Na temat wewnętrznej struktury indeksów można przeczytać tutaj:
- [https://technet.microsoft.com/en-us/library/2007.03.sqlindex.aspx](https://technet.microsoft.com/en-us/library/2007.03.sqlindex.aspx)
- [https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql](https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql)
- [https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql](https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql)
- [https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-indexes-transact-sql](https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-indexes-transact-sql)

Sprawdź jakie informacje można wyczytać ze statystyk indeksu:

```sql
select *  
from sys.dm_db_index_physical_stats (db_id('adventureworks2017')  
,object_id('humanresources.employee')  
,null -- null to view all indexes; otherwise, input index number  
,null -- null to view all partitions of an index  
,'detailed') -- we want all information
```

Jakie są według Ciebie najważniejsze pola?

---
> Wyniki: 

```
Najważniejsze wydaje się być `avg_fragmentation_in_percent`, wartości znacznie wyższe niż 0 (wg. dokmentacji -10% może być akceptowalne) sprawiają, że obniżna się efektyność korzystania z indeksu.
Kolumna `avg_page_space_used_in_percent` także wydaje się istotna. Optymalną wartością jest 100. Im bliżej tej wartości tym efektywniej wypełniamy liście w drzewie. Jeśli wartość jest niska to bardzo nieefektywnie używamy przestrzeni dyskowej.
```

---




Sprawdź, które indeksy w bazie danych wymagają reorganizacji:

```sql
use adventureworks2017  
  
select object_name([object_id]) as 'table name',  
index_id as 'index id'  
from sys.dm_db_index_physical_stats (db_id('adventureworks2017')  
,null -- null to view all tables  
,null -- null to view all indexes; otherwise, input index number  
,null -- null to view all partitions of an index  
,'detailed') --we want all information  
where ((avg_fragmentation_in_percent > 10  
and avg_fragmentation_in_percent < 15) -- logical fragmentation  
or (avg_page_space_used_in_percent < 75  
and avg_page_space_used_in_percent > 60)) --page density  
and page_count > 8 -- we do not want indexes less than 1 extent in size  
and index_id not in (0) --only clustered and nonclustered indexes
```


---
> Wyniki: 
> zrzut ekranu/komentarz:

<img src="_img/zad3-1.png" alt="image" width="500" height="auto">

```
Te tabele posiadają kolumnę ModifiedDate, co sugeruje, że rekordy są w jakiś sposób update'owane. To może powodować fragmentację indexów
```

---



Sprawdź, które indeksy w bazie danych wymagają przebudowy:

```sql
use adventureworks2017  
  
select object_name([object_id]) as 'table name',  
index_id as 'index id'  
from sys.dm_db_index_physical_stats (db_id('adventureworks2017')  
,null -- null to view all tables  
,null -- null to view all indexes; otherwise, input index number  
,null -- null to view all partitions of an index  
,'detailed') --we want all information  
where ((avg_fragmentation_in_percent > 15) -- logical fragmentation  
or (avg_page_space_used_in_percent < 60)) --page density  
and page_count > 8 -- we do not want indexes less than 1 extent in size  
and index_id not in (0) --only clustered and nonclustered indexes
```

---
> Wyniki: 
> zrzut ekranu/komentarz:

<img src="_img/zad3-2.png" alt="image" width="500" height="auto">

```
Przebudowy wymagają tylko 3 indeksy - wszystkie na tabeli Person. Rekordy z tej tabeli również są modyfikowane, a dodatkowo jest ona dość spora (w porównaniu do tych z poprzedniego podpunktu), co może powodować dużą liczbę modyfikacji i tym samym fragmentację.
```

---

Czym się różni przebudowa indeksu od reorganizacji?

(Podpowiedź: [http://blog.plik.pl/2014/12/defragmentacja-indeksow-ms-sql.html](http://blog.plik.pl/2014/12/defragmentacja-indeksow-ms-sql.html))

---
> Wyniki: 

```
Przebudowa oznacza DROP indeksu i utworzenie go do nowa. Może być wykonana online lub offline (wtedy niestaty indeks nie jest dostępny)

Reorganizacja nie usuwa indeksu, tylko restrukturyzuje stronę indeksu. Wykonywana online.
```

---

Sprawdź co przechowuje tabela sys.dm_db_index_usage_stats:

---
> Wyniki: 

```sql
select * from sys.dm_db_index_usage_stats
```

<img src="_img/zad3-3.png" alt="image" width="500" height="auto">


```
Tabela zawieraj informacje o różnych operacjach dokonywanych na indeksach i ile razy lub kiedy ich dokonano.
```

---


Napraw wykryte błędy z indeksami ze wcześniejszych zapytań. Możesz użyć do tego przykładowego skryptu:

```sql
use adventureworks2017  
  
--table to hold results  
declare @tablevar table(lngid int identity(1,1), objectid int,  
index_id int)  
  
insert into @tablevar (objectid, index_id)  
select [object_id],index_id  
from sys.dm_db_index_physical_stats (db_id('adventureworks2017')  
,null -- null to view all tables  
,null -- null to view all indexes; otherwise, input index number  
,null -- null to view all partitions of an index  
,'detailed') --we want all information  
where ((avg_fragmentation_in_percent > 15) -- logical fragmentation  
or (avg_page_space_used_in_percent < 60)) --page density  
and page_count > 8 -- we do not want indexes less than 1 extent in size  
and index_id not in (0) --only clustered and nonclustered indexes  
  
select 'alter index ' + ind.[name] + ' on ' + sc.[name] + '.'  
+ object_name(objectid) + ' rebuild'  
from @tablevar tv  
inner join sys.indexes ind  
on tv.objectid = ind.[object_id]  
and tv.index_id = ind.index_id  
inner join sys.objects ob  
on tv.objectid = ob.[object_id]  
inner join sys.schemas sc  
on sc.schema_id = ob.schema_id
```


Napisz przygotowane komendy SQL do naprawy indeksów:

---
> Wyniki: 

```sql
ALTER INDEX XMLPATH_Person_Demographics ON Person.Person REBUILD WITH (MAXDOP = 1);
ALTER INDEX XMLPROPERTY_Person_Demographics ON Person.Person REBUILD WITH (MAXDOP = 1);
ALTER INDEX XMLVALUE_Person_Demographics ON Person.Person REBUILD WITH (MAXDOP = 1);
```

```
MAXDOP = 1 jest konieczne, ozancza ono, że tylko jeden proces będzie wykonywał przebudowywanie indeksu. Wszystko odbędzie się seryjnie. Zwiększa to wydajność indeksu i zmneijsza fragmentację, ale trwa dłużej. Bez tego paramteru indeksy wciąż pojawiały się jako kandydaci do przebudowania.
```

---

<div style="page-break-after: always;"></div>

# Zadanie 4 - Budowa strony indeksu

## Dokumentacja

Celem kolejnego zadania jest zapoznanie się z fizyczną budową strony indeksu 
- [https://www.mssqltips.com/sqlservertip/1578/using-dbcc-page-to-examine-sql-server-table-and-index-data/](https://www.mssqltips.com/sqlservertip/1578/using-dbcc-page-to-examine-sql-server-table-and-index-data/)
- [https://www.mssqltips.com/sqlservertip/2082/understanding-and-examining-the-uniquifier-in-sql-server/](https://www.mssqltips.com/sqlservertip/2082/understanding-and-examining-the-uniquifier-in-sql-server/)
- [http://www.sqlskills.com/blogs/paul/inside-the-storage-engine-using-dbcc-page-and-dbcc-ind-to-find-out-if-page-splits-ever-roll-back/](http://www.sqlskills.com/blogs/paul/inside-the-storage-engine-using-dbcc-page-and-dbcc-ind-to-find-out-if-page-splits-ever-roll-back/)

Wypisz wszystkie strony które są zaalokowane dla indeksu w tabeli. Użyj do tego komendy np.:

```sql
dbcc ind ('adventureworks2017', 'person.address', 1)  
-- '1' oznacza nr indeksu
```

Zapisz sobie kilka różnych typów stron, dla różnych indeksów:

---
> Wyniki: 

```
Otrzymano PageType: 1,2,3 i 10. Typ 10 oznacza, że na tej stronie znajduje się sam indeks. Na stronach typu 1 znajduą się dane, typu 2 znajdują sie dane indkesowe, typ 3 dane tekstowe.
```

---

Włącz flagę 3604 zanim zaczniesz przeglądać strony:

```sql
dbcc traceon (3604);
```

Sprawdź poszczególne strony komendą DBCC PAGE. np.:

```sql
dbcc page('adventureworks2017', 1, 13720, 3);
```


Zapisz obserwacje ze stron. Co ciekawego udało się zaobserwować?

---
> Wyniki: 

```
Dostajemy header strony z różnymi metadanymi, np. numerami stron poprzedniej i kolejnej, liczbą wolnych danych itp.
Następnie dostajemy surowy dump całej strony.
```

---

Punktacja:

|   |   |
|---|---|
|zadanie|pkt|
|1|3|
|2|3|
|3|3|
|4|1|
|razem|10|