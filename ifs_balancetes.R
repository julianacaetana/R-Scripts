#### Balancetes ####

ifs_balancetes_cnpj <- function(cnpj) {
  
  data <- paste(year(rollback(Sys.Date())),month(rollback(Sys.Date())),sep="")
  data <-  Sys.Date() - months(0:2)
  database <- paste(year(rollback(data[3])),str_pad( month(rollback(data[3])),2,"left",'0'),sep="")
  
  url <- "http://www4.bcb.gov.br/fis/cosif/cont/balan/individualizados/DATA/TIPO/ARQUIVO.ZIP"
  
  PREFIXO = "http://www4.bcb.gov.br/fis/cosif/cont/balan/individualizados"
  DATA = database
  TIPO = "4040" 
  CNPJ = cnpj
  ARQUIVO.ZIP = paste(DATA, "-", TIPO, "-", CNPJ, ".ZIP", sep = "")
  
  
 download.file(paste(PREFIXO,DATA,TIPO,ARQUIVO.ZIP, sep ="/"), ARQUIVO.ZIP)

 return("Ok")
  
  
}



for (i in 1:nrow(lista.outros.links)) {
  


if(lista.outros.links$dataset[i] == "ifs-balancetes"){
  if( lista.outros.links$nome[i] == "Balancete Patrimonial Individualizado" ){
    lista.outros.links$status[i] <- "OK"
    dow <- as.data.frame(getHTMLLinks(readLines("http://www4.bcb.gov.br/fis/cosif/cosif.asp")))
    names(dow) <- "link"
    dow <- filter(dow, dow$link %like% "cont/")
    dow <- bind_cols(dow, readHTMLTable(readLines("http://www4.bcb.gov.br/fis/cosif/cosif.asp"), encoding="UTF-8")) 
    
    
    for (x in 1:nrow(dow)) {
      download.file(paste("https://www4.bcb.gov.br/fis/cosif/",dow$link[x], sep =""), paste(dow$Segmento[x],"ZIP", sep="."))
    }
  }
  
  if( lista.outros.links$nome[i] == "Balancetes (Transferência de arquivos CSV)" ){
    lista.outros.links$status[i] <- "OK"
    temp <-  html("https://www4.bcb.gov.br/fis/cosif/balancetes.asp")
    dow <-
      as.data.frame(html_attr(html_nodes(temp, xpath = '//*[@id="Bancos"]/option'), "value"))
    names(dow) <- "link"
    Cooperativas <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Cooperativas"]/option'),
        "value"
      ))
    names(Cooperativas) <- "link"
    dow <- bind_rows(dow, Cooperativas)
    Consorcios <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Consorcios"]/option'),
        "value"
      ))
    names(Consorcios) <- "link"
    dow <- bind_rows(dow, Consorcios)
    Sociedades <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Sociedades"]/option'),
        "value"
      ))
    names(Sociedades) <- "link"
    dow <- bind_rows(dow, Sociedades)
    Conglomerados <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Conglomerados"]/option'),
        "value"
      ))
    names(Conglomerados) <- "link"
    dow <- bind_rows(dow, Conglomerados)
    
    Conglomerados <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Conglomerados"]/option'),
        "value"
      ))
    names(Conglomerados) <- "link"
    dow <- bind_rows(dow, Conglomerados)
    
    Prudencial <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Prudencial"]/option'),
        "value"
      ))
    names(Prudencial) <- "link"
    dow <- bind_rows(dow, Prudencial)
    
    Combinados <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Combinados"]/option'),
        "value"
      ))
    names(Combinados) <- "link"
    dow <- bind_rows(dow, Combinados)
    Liquidacao <-
      as.data.frame(html_attr(
        html_nodes(temp, xpath = '//*[@id="Liquidacao"]/option'),
        "value"
      ))
    names(Liquidacao) <- "link"
    dow <- bind_rows(dow, Liquidacao)
    
    
    
    
    for (y in 1:nrow(dow)) {
      arquivo <- str_split(dow$link[y],  "/")[[1]][length(str_split(dow$link[y],  "/")[[1]])]
      download.file(paste("https://www4.bcb.gov.br",dow$link[y], sep =""), arquivo)
    }
    
    rm(Combinados, Conglomerados, Cooperativas, Liquidacao, Sociedades, Prudencial, Consorcios, temp, dow)
    
  }
  

  

    if(lista.outros.links$nome[i] == "Consolidado Financeiro Individualizado"){
      lista.outros.links$status[i] <- "OK"
      for (z in 1:nrow(conglomerados)) {
        tryCatch({ifs_balancetes_cnpj(conglomerados$cnpj[z])},error = function(e) {
          cat("ERROR : ", conditionMessage(e), "\n")
        })
        
      }
      
    }
  
}
  
}
  
  
  



