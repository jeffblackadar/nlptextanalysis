---
title: "faillog"
author: "Jeff Blackadar"
date: "September 14, 2019"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Fail log

Created new R Project and R program
Created database using SQL in create_db.sql
Created .cnf file to connect to database

Checked connection to database from R
rmysql.settingsfile<-"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\corpus_entities_nlptextanalysis.cnf"
rmysql.db<-"corpus_entities_nlptextanalysis"
mydb<-dbConnect(RMySQL::MySQL(),default.file=rmysql.settingsfile,group=rmysql.db)
#Check we connected
dbListTables(mydb)

