library(rJava)
#options(java.parameters = "-Xmx8000m")
options(java.parameters = "-Xms4096m -Xmx4096m")
.jinit()
#This code is from
#https://rpubs.com/lmullen/nlp-chapter

#install.packages("rJava")
#install.packages("RMySQL")
#install.packages("NLP",version = "0.1-11", repos="https://cran.r-project.org/src/contrib/Archive/NLP/")
#install.packages("openNLP",version = "2.6")
#install.packages("RWeka")
#install.packages("qdap")
#install.packages("stringr")
#install.packages("RMariaDB")
#install.packages("openNLPmodels.en", repos = "http://datacube.wu.ac.at/", type = "source")

library(rJava)
library(NLP)
library(openNLP)
library(RWeka)
library(RMariaDB)
library(qdap)
library(stringr)
library(magrittr)


#for spell checking
#options(java.parameters = "-Xms4096m -Xmx4096m")

#set value of tab character
tabChar = 9
mode(tabChar) <- "raw"

spellCheckOrig<-c("")
spellCheckCorrect<-c("")
spellCheckNorvig<-c("")


# Read in big.txt, a 6.5 mb collection of different English texts.
raw_text <- paste(readLines("C:/a_orgs/carleton/hist3814/R/graham_fellowship/norvigs-big-plus-placesx2.txt"), collapse = " ")
# Make the text lowercase and split it up creating a huge vector of word tokens.
split_text <- strsplit(tolower(raw_text), "[^a-z]+")
# Count the number of different type of words.
word_count <- table(split_text)
# Sort the words and create an ordered vector with the most common type of words first.
sorted_words <- names(sort(word_count, decreasing = TRUE))

setwd("C:/a_orgs/carleton/hist3814/R/nlptextanalysis")

#Rasmus Bååth's Research Blog
#http://www.sumsar.net/blog/2014/12/peter-norvigs-spell-checker-in-two-lines-of-r/
correctNorvig <- function(word) {
  # Calculate the edit distance between the word and all other words in sorted_words.
  edit_dist <- adist(word, sorted_words)
  # Calculate the minimum edit distance to find a word that exists in big.txt 
  # with a limit of two edits.
  min_edit_dist <- min(edit_dist, 2)
  # Generate a vector with all words with this minimum edit distance.
  # Since sorted_words is ordered from most common to least common, the resulting
  # vector will have the most common / probable match first.
  proposals_by_prob <- c(sorted_words[ edit_dist <= min(edit_dist, 2)])
  # In case proposals_by_prob would be empty we append the word to be corrected...
  proposals_by_prob <- c(proposals_by_prob, word)
  # ... and return the first / most probable word in the vector.
  proposals_by_prob[1]
}



printAndStoreEntities<-function(entityInEdition,outputFileHtmlCon, entity_table, entity_table_id_name, entity_document_x_table, entity_document_x_table_id_name, table_id_source_document){
  spellCheckOrig<-c("")
  spellCheckMisSpelled<-c("")
  spellCheckCorrect<-c("")
  spellCheckNorvig<-c("")
  
  topicsInEditionString<-paste(entityInEdition, collapse=', ' )
  thisCell<-paste('<td>',topicsInEditionString,'</td>',sep="")
  #  writeLines(thisCell,outputFileHtmlCon)
  
  for(entity in entityInEdition) {
    
    
    #entitySql = gsub("'", "''", entity)
    #entitySql = gsub("’", "''", entitySql)
    #entitySql = gsub(tabChar, " ", entitySql)
    #entitySql = gsub("\n", " ", entitySql)
    #entitySql = gsub("\t", " ", entitySql)
    #entitySql = gsub("\'", "''", entitySql)
    #entitySql = gsub("\\", "", entitySql, fixed=TRUE)
    
    
    
    correctedEntity = entity
    
    
    correctedEntity = gsub(tabChar, " ", correctedEntity)
    correctedEntity = gsub("\n", " ", correctedEntity)
    correctedEntity = gsub("\t", " ", correctedEntity)
    correctedEntitySql = gsub("'''''''", " ", correctedEntity)
    correctedEntitySql = gsub("''''''", " ", correctedEntitySql)
    correctedEntitySql = gsub("'''''", " ", correctedEntitySql)
    correctedEntitySql = gsub("''''", " ", correctedEntitySql)
    correctedEntitySql = gsub("'''", " ", correctedEntitySql)
    correctedEntitySql = gsub("''", " ", correctedEntitySql)
    correctedEntitySql = gsub("'", "''", correctedEntitySql)
    correctedEntitySql = gsub("’", "''", correctedEntitySql)
    correctedEntitySql = gsub("\'", "''", correctedEntitySql)
    correctedEntitySql = gsub("\\", "", correctedEntitySql, fixed=TRUE)
    correctedEntitySql = gsub("''''", " ", correctedEntitySql)
    print(correctedEntitySql)
    
    if(nchar(correctedEntitySql)>99){
      correctedEntitySql=substr(correctedEntitySql,1,99)
    }
    #Store people into database
    #first, check if it is already in the database
    query <-
      paste("select * from ",entity_table," where name='",
            correctedEntitySql,
            "'",
            sep = '')
    print (query)
    
    rs = dbSendQuery(mydb, query)
    dbRows <- dbFetch(rs)
    dbClearResult(rs)
    

    #dbFetch() always returns a data.frame with as many rows as records were fetched and as many columns as fields in the result set, even if the result is a single value or has one or zero rows
    
    if (nrow(dbRows) == 0) {
      
      #------- Do spell check only on new words 
      nameSpellChecked=""
      
      # correctedEntityWords = strsplit(correctedEntity, " ")
      # correctedEntityWordsNorvig = strsplit(correctedEntity, " ")
      # 
      # #sometimes which_misspelled() fails and so it is in a tryCatch()
      # misSpelledWords <-tryCatch(
      #   {
      #     which_misspelled(correctedEntity, suggest=TRUE)
      #   },
      #   error=function(cond) {
      #     NULL
      #   },
      #   warning=function(cond) {
      #     NULL
      #   },
      #   finally={
      #     NULL
      #   })
      # 
      # 
      # if(is.null(misSpelledWords)){
      #   #The R spell checker has not picked up a problem, so no need to do further checking.
      #   misSpelled=FALSE
      # } else {
      #   for(counter in 1:length(misSpelledWords[[1]])){
      #     misSpelled=TRUE
      #     wordNum = as.integer(misSpelledWords[[1]][counter])
      #     correctedEntityWords[[1]][wordNum] = misSpelledWords[counter,3]
      #     correctedEntityWordsNorvig[[1]][wordNum] = correctNorvig(correctedEntityWordsNorvig[[1]][wordNum])
      #   }
      #   correctedEntitySpellChecked = paste(correctedEntityWords[[1]],collapse=" ")
      #   correctedEntityNorvig = paste(correctedEntityWordsNorvig[[1]],collapse=" ")
      #   nameSpellChecked=""
      #   if(!str_to_upper(correctedEntity)==str_to_upper(correctedEntityNorvig)){
      #     #We have found a suggested correction
      #     nameSpellChecked=correctedEntityNorvig
      #     
      #     print(paste(correctedEntity,misSpelled,correctedEntitySpellChecked,correctedEntityNorvig,sep="  ---  "))
      #     
      #     #keep a vector of the words to make into a dataframe so that we can check the results of the spell check.  Remove this after training of the spell checker is done.
      #     #spellCheckOrig<-c(spellCheckOrig,correctedEntity)
      #     #spellCheckMisSpelled<-c(spellCheckMisSpelled,misSpelled)
      #     #spellCheckCorrect<-c(spellCheckCorrect,correctedEntitySpellChecked)
      #     #spellCheckNorvig<-c(spellCheckNorvig,correctedEntityNorvig) 
      #     
      #   }
      # }
      # 
      # #Clean up any symbols that will cause an SQL error when inserted into the database
      # nameSpellCheckedSql = gsub("'''''''", "\"", nameSpellChecked)
      # nameSpellCheckedSql = gsub("''''''", "\"", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("'''''", "\"", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("''''", "\"", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("'''", "\"", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("''", "\"", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("'", "''", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("’", "''", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("\'", "''", nameSpellCheckedSql)
      # nameSpellCheckedSql = gsub("\\", "", nameSpellCheckedSql, fixed=TRUE)
      
      #-------
      
      query <-
        paste(
          "INSERT INTO ",entity_table," (name) VALUES(LEFT(RTRIM('",
          correctedEntitySql,
          "'),99))",
          sep = ''
        )
      print (query)
      rsInsert = dbSendQuery(mydb, query)
      dbClearResult(rsInsert)
    }
    
    #do cross reference
    
    # get handle on ID    
    query<-paste("select ",entity_table_id_name," from ",entity_table," where name='",correctedEntitySql,"'",sep='')
    print(query) 
    rs = dbSendQuery(mydb,query)
    dbRows<-dbFetch(rs)
    dbClearResult(rs)
    if (nrow(dbRows)==0){
      print (paste("Problem: zero rows for ",query,sep=''))
    } 
    
    else {
      #print (dbRows[[1]])
      entity_table_id<-dbRows[[1]]
      
      query<-paste("select ",entity_document_x_table_id_name," from ",entity_document_x_table," where ", entity_document_x_table_id_name, "=",entity_table_id," and id_source_document=", table_id_source_document,sep='')
      rs = dbSendQuery(mydb,query)
      dbRows<-dbFetch(rs)
      dbClearResult(rs)
      if (nrow(dbRows)==0){
        
        query <-
          paste(
            "INSERT INTO ",entity_document_x_table," (", entity_document_x_table_id_name,", id_source_document) VALUES(",
            entity_table_id,",",table_id_source_document,
            ")",
            sep = ''
          )
        
        #print (query)
        rsInsert = dbSendQuery(mydb, query)
        dbClearResult(rsInsert)
      }
    }
  }
  #spellCheckDF<-data.frame(spellCheckOrig,spellCheckNorvig)
  #edit(spellCheckDF)
}

rmariadb.settingsfile <-
  "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\corpus_entities_nlptextanalysis.cnf"
rmariadb.db <- "corpus_entities_nlptextanalysis"

mydb <- dbConnect(RMariaDB::MariaDB(),default.file=rmariadb.settingsfile,group=rmariadb.db) 
#Check we connected
dbListTables(mydb)
#query <- "select * from source_documents where source_document_name='sage_historical_theory.txt'"
#rsInsert = dbSendQuery(mydb, query)



# Extract entities from an AnnotatedPlainTextDocument
# entities <- function(doc, kind) {
#   s <- doc$content
# 
#   a <- annotation(doc)[[1]]
#   b <- annotation(doc)[3]
#   print("entities function")
#   a$features
#   print(a$features)
#   print("x")
#   
#   x <- features(doc)
#   print(x$kind)
#   #x
#   #print(x[2])
#   print("endx")
#   print("entities function- b")
#   b
#   print("entities function- end-b")
#   print(class(a))
#   print(head(a))
#   if (hasArg(kind)) {
#     k <- sapply(a$features, `[[`, "kind")
#     s[a[k == kind]]
#   } else {
#     s[a[a$type == "entity"]]
#   }
# }


entities <- function(doc, kind) {
  s <- doc$content
  a <- NLP::annotations(doc)[[1]]
  if(hasArg(kind)) {
    k <- sapply(a$features, `[[`, "kind")
    s[a[k == kind]]
  } else {
    s[a[a$type == "entity"]]
  }
}

#openconnecton to read file
inputFile <- "nlp_documents_to_analyse.txt"


inputCon  <- file(inputFile, open = "r")

while (length(urlLine <-
              readLines(inputCon, n = 1, warn = FALSE)) > 0) {
  editionFileName <- urlLine
  #Store document into database
  #first, check if it is already in the database
  query <-
    paste(
      "select * from source_documents where source_document_name='",
      editionFileName,
      "'",
      sep = ''
    )
  print (query)
  rs_ent = RMariaDB::dbSendQuery(mydb, query)
  dbRows <- dbFetch(rs_ent)
  dbClearResult(rs_ent)
  if (nrow(dbRows) == 0) {
    query <-
      paste(
        "INSERT INTO source_documents (source_document_name,source_document_base_url,source_document_file_extension_1,source_document_file_extension_2) VALUES('",
        editionFileName,
        "','",
        urlLine,
        "','pdf','txt')",
        sep = ''
      )
    #print (query)
    rsInsert = dbSendQuery(mydb, query)
    dbClearResult(rsInsert)
  }
  
  # get handle on ID
  query <-
    paste(
      "select id_source_document,source_document_processed from source_documents where source_document_name='",
      editionFileName,
      "'",
      sep = ''
    )
  rs = dbSendQuery(mydb, query)
  print("Starting")
  dbRows <- dbFetch(rs)
  if (nrow(dbRows) == 0) {
    print (paste("Problem: zero rows for ", query, sep = ''))
  } else {
    print (dbRows[[1]])
    id_source_document <- dbRows[[1]]
    source_document_processed <- dbRows[[2]]
    #Was this row already processed? If it was source_document_processed=1.
    if (source_document_processed == 0) {
      print("Perform Natural Language Processing on the file")
      
      inputEquityTextFile <-
        paste(editionFileName,
              sep = "")
      
      inputEquityTextFileCon  <-
        file(inputEquityTextFile, open = "r")
      equityEditionText <-
        paste(readLines(inputEquityTextFileCon, n = -1, warn = TRUE),
              collapse = "\n")
      close(inputEquityTextFileCon)
      
      equityEditionString <- as.String(equityEditionText)
      
      word_ann <- openNLP::Maxent_Word_Token_Annotator()
      sent_ann <- openNLP::Maxent_Sent_Token_Annotator()
      
      equityEdition_annotations <-
        annotate(equityEditionString, list(sent_ann, word_ann))
      class(equityEdition_annotations)
      head(equityEdition_annotations)
      equityEdition_doc <-
        AnnotatedPlainTextDocument(equityEditionString, equityEdition_annotations)
      sents(equityEdition_doc)
      
      person_ann <- Maxent_Entity_Annotator(kind = "person")
      location_ann <- Maxent_Entity_Annotator(kind = "location")
      organization_ann <-
        Maxent_Entity_Annotator(kind = "organization")

      pipeline <- list(sent_ann,
                       word_ann,
                       person_ann,
                       location_ann,
                       organization_ann
                   )
      equityEdition_annotations <-
        annotate(equityEditionString, pipeline)
      equityEdition_doc <-
        AnnotatedPlainTextDocument(equityEditionString, equityEdition_annotations)
      
      peopleInEdition <-
        c(sort(unique(
          entities(equityEdition_doc, kind = "person")
        )))
      printAndStoreEntities(
        peopleInEdition,
        outputFilePeopleHtmlCon,
        "entities_people",
        "id_entities_person",
        "people_x_sourcedocuments",
        "id_entities_person",
        id_source_document
      )
      
      locationsInEdition <-
        sort(unique(entities(equityEdition_doc, kind = "location")))
      printAndStoreEntities(
        locationsInEdition,
        outputFileLocationsHtmlCon,
        "entities_locations",
        "id_entities_location",
        "locations_x_sourcedocuments",
        "id_entities_location",
        id_source_document
      )
      
      organizationsInEdition <-
        sort(unique(entities(equityEdition_doc, kind = "organization")))
      printAndStoreEntities(
        organizationsInEdition,
        outputFileOrganizationsHtmlCon,
        "entities_organizations",
        "id_entities_organization",
        "organizations_x_sourcedocuments",
        "id_entities_organization",
        id_source_document
      )
      
      #Now that the processing is complete, update the row in source_documents to indicate that.
      query <-
        paste(
          "update source_documents SET source_document_processed=1 where id_source_document =",
          id_source_document,
          "",
          sep = ''
        )
      rs = dbSendQuery(mydb, query)
      dbClearResult(rs)
      #print(query)
      
    }
  }




 objectsToKeep <-
   c(
     "correctNorvig",
     "tabChar",
     "inputCon",
     "mydb",
     "urlLine",
     "entities",
     "printAndStoreEntities",
     "word_count",
     "sorted_words"
   )
 rm(list = setdiff(ls(), objectsToKeep))
 gc()
}


close(inputCon)
dbDisconnect(mydb)

gc()
