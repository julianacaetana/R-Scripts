### Caso ocorra esse erro ao tentar outilizar bibliotecas como o rjava utilizar o comando abaixo###

#Error: package or namespace load failed for ‘rJava’:
# .onLoad failed in loadNamespace() for 'rJava', details:
#  call: dirname(this$RuntimeLib)
#  error: a character vector argument expected

###O comando pode ser executado no console
###O caminho é onde o seu Java está instalado

> Sys.setenv(JAVA_HOME='C:\Program Files (x86)\Java\jre1.8.0_181')



###Esse erro pode ocorrer por executar o R 64 mas o java ser 32 ou vice-versa.
