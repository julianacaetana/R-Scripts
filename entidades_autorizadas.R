##### Dados cadastrais de entidades autorizadas #####

for (i in 1:nrow(lista.outros.links)) {
  
  if (lista.outros.links$dataset[i] == "dados-cadastrais-de-entidades-autorizadas"){
  
  if (lista.outros.links$nome[i] == "Dados Cadastrais das Entidades Autorizadas" || lista.outros.links$nome[i] == "Dados Cadastrais das Cooperativas Autorizadas"  ) {
   
    url <-
      paste(
        lista.outros.links$url[i],
        "(dataBase=@dataBase)?@dataBase='",
        data,
        "'&$format=json",
        sep = ""
      )
    download.file(url,
                  paste(lista.outros.links$nome[i], data, ".json"))
    
    lista.outros.links$status[i] <- "OK"
    
    entidades <-
      fromJSON(readLines(url))$value
    
    instituicoes <- data.frame()
    for (i in 1:length(entidades)) {
      instituicoes  <-
        bind_rows(
          instituicoes,
          data.frame(
            cnpj = if (!is.null(entidades[[i]]$codigoCNPJ8))
              str_pad(as.character(entidades[[i]]$codigoCNPJ8), 8, "left", '0')
            else
              "N/A",
            nome = entidades[[i]]$nomeEntidadeInteresse,
            cnpj14 = if (is.null(entidades[[i]]$codigoCNPJ14))
              "N/A"
            else
              str_pad(as.character(entidades[[i]]$codigoCNPJ14), 14, "left", '0')
            ,
            stringsAsFactors = F
          )
        )
    }
    
    
   
  }
    else{
      
      download.file(lista.outros.links$url[i],
                    paste(str_trim(lista.outros.links$nome[i]), ".json",sep = ""))
      lista.outros.links$status[i] <- "OK"
    }
 
  
  }
  
  
  }

