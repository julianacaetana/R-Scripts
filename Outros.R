
######Carregando as bibliotecas#######

library(rjson)
library(dplyr)
library(stringr)
library(reshape2)
library(data.table)
library(XML)
library(rvest)
library(lubridate)

setwd("D:/Pós Graduação/Projeto Aplicado/Scraping/Dados Abertos BC/Outros Datasets")

#######  Definindo as fontes ########

lista.datasets <-
  as.data.frame(fromJSON(
    readLines("http://dadosabertos.bcb.gov.br/api/action/package_list")
  )$result, stringsAsFactors = F)
names(lista.datasets) <- "dataset"
lista.datasets <- bind_cols(lista.datasets,
                            data.frame(sgs = str_detect(lista.datasets$dataset, "[0-9]-")))
lista.datasets <- filter(lista.datasets, lista.datasets$sgs == F)



###### Descobrindo links ######




lista.outros.links <- data.frame() ##dataframe principal

for (i in 1:nrow(lista.datasets)) {
  cat(".", i)
  
  temp <- 
    fromJSON(readLines(
      paste(
        "http://dadosabertos.bcb.gov.br/api/action/package_show?id=",
        lista.datasets$dataset[i],
        sep = ""
      )
    )) ##recupera informações sobre o dataset
  
  
  
  
  for (x in 1:length(temp$result$resources)) {
    t <- data.frame(
      dataset = lista.datasets$dataset[i],
      nome = temp$result$resources[[x]]$name,
      formato = temp$result$resources[[x]]$format,
      url = temp$result$resources[[x]]$url,
      
      stringsAsFactors = FALSE
    ) ##gera um dataframe com os links
    
    
    lista.outros.links <- bind_rows(lista.outros.links, t) #coloca os dados do dataset no dataframe principal
    
  }
}

lista.outros.links <-
  filter(
    lista.outros.links,
    lista.outros.links$nome != 'API - Documentação Swagger' &
      lista.outros.links$nome != 'API - Navegador de Dados' &
      lista.outros.links$nome != 'API - Endpoint OData' &
      lista.outros.links$nome != 'Documentação'  &
      lista.outros.links$formato != 'HTML'
  ) 

for (i in 1:nrow(lista.outros.links)) {
  if(lista.outros.links$url %like% "olinda.bcb.gov.br/olinda/servico" & lista.outros.links$url %like%  "aplicacao#!" ){
    lista.outros.links$url<- str_replace(lista.outros.links$url,"aplicacao#!","odata")
  }
}

data <- format(Sys.Date(), "%m-%d-%Y")

for (i in 1:nrow(lista.outros.links)) {
  if(lista.outros.links$nome[i] == "Dados Cadastrais das Entidades Autorizadas" ){
    #lista.outros.links$url[i] <- paste(lista.outros.links$url[i],"(dataBase=@dataBase)?@dataBase='",data,"'&$format=json",sep="")  
    download.file(lista.outros.links$url[i], paste("Dados Cadastrais das Entidades Autorizadas", data, ".json"))
    entidades <- fromJSON(readLines(lista.outros.links$url[i]))$value
    
    instituicoes <- data.frame()
    for (i in 1:length( entidades)) {
      instituicoes  <- 
                      bind_rows(instituicoes,
                      data.frame(
                         cnpj = if(!is.null(entidades[[i]]$codigoCNPJ8)) str_pad(as.character(entidades[[i]]$codigoCNPJ8),8,"left",'0') else "N/A",
                         nome = entidades[[i]]$nomeEntidadeInteresse,
                         cnpj14 =if(is.null(entidades[[i]]$codigoCNPJ14 )) "N/A"
            else str_pad(as.character(entidades[[i]]$codigoCNPJ14),14,"left",'0') 
                         ,stringsAsFactors = F )
      )
    }
    
    
  }
  
}

ifs_balancetes()
##### Download dos arquivos ######



source("ifs_balancetes.R")


