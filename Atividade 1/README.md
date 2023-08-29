# Atividade de Linux

Esse é o repositório das atividades de Linux do programa de bolsas da CompassUOL. Aqui será dado o passo a passo para que qualquer um possa recriar esses projetos.

Obs: Os nomes de algumas ferramentas que envolvem os serviços da AWS serão dados em inglês, visto que a console AWS utilizada para a atividade estava configurada para
a língua inglesa.

## Sobre

O projeto consiste numa instância EC2 que funciona como um servidor NFS(Network File System), ou seja, um servidor de 
compartilhamento de arquivos que usa o protocolo NFS para permitir o acesso remoto a arquivos e diretórios entre computadores numa rede. 
Nesse servidor, um web server Apache está ativo e rodando, e um script cria um arquivo de log a cada 5 minutos por meio do cron para validar o status do Apache. 
O arquivo deve conter as seguintes informações:  Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline.
Juntamente ao servidor, teremos uma outra instância EC2 que assumirá o papel de cliente, ou seja, aquele que irá acessar os dados compartilhados.

## Configurações da AWS

Antes de mais nada, é preciso ter uma conta na AWS e, nela, ter acesso aos serviços de EC2, VPC e EFS. Eles serão essenciais para que tudo funcione
corretamente.

### Security Group

O Security Group a ser utilizado pelas instâncias precisa permitir que os protocolos SSH, HTTP/HTTPS e NFS possam ser utilizados nas suas portas padrão. Para isso,
no menu da ferramenta Security Groups(que faz parte do serviço de EC2), será necessário:
+ Clicar no botão "Create Security Group"
+ Dar um nome e uma descrição para o Security Group
+ Adicionar as regras de entrada como estão na imagem abaixo(é possível alterar as configurações de tráfego para regular quem poderá acessar a intância)
+ Clicar no botão "Create security group" para finalizar a configuração e criar o security group.

![imagem_2023-07-09_192748097](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/baee8afe-536c-4d9e-8018-b7326aa5dd38)

### VPC

A configuração correta da VPC é essencial para o sucesso da atividade, afinal, o serviço do Apache, por exemplo, não funcionará se não houver meios da rede se conectar à internet. Sendo assim,
para criar nossa VPC devemos, no menu do serviço de VPC, fazer o seguinte:
+ Selecionar a opção "Your VPCs"
+ Clicar no botão "Create VPC"
+ Dar um nome à VPC e especificar o endereço IPv4 desejado(Em caso de dúvida, coloque algo como 192.168.0.0/16)
+ Clicar no botão "Create VPC"

![imagem_2023-07-09_200920206](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/9ac4c904-27a1-4420-9604-aa79a0eaebcb)

  
Em seguida, é preciso criar uma subnet:
+ No menu "Subnets", clique no botão "Create subnet"
+ Selecione a VPC criada anteriormente
+ Dê um nome à subnet, selecione uma AZ(na dúvida, selecione us-east-1a) e coloque um endereço IPv4 adequado(na dúvida, coloque 192.168.1.0/24)
+ Clique no botão "Create subnet"

![imagem_2023-07-09_201546009](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/19675534-1645-488b-9aee-eb4f728379f4)

Agora, criaremos uma route table que direcione o tráfego da nossa subnet para o internet gateway que criaremos mais a frente:
+ No menu "Route Tables", clique no botão "Create route table"
+ Dê um nome para a route table e selecione a VPC adequada.
+ Clique em "create route table"
+ Com a route table já criada, selecione-a e clique na aba "subnet associations"
+ Clique no botão "Edit subnet associations", selecione a subnet criada anteriormente e salve as configurações
![imagem_2023-07-09_202843430](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/c0f3de33-b74c-4ec4-a31b-e513605f305e)


Finalmente, criaremos o internet gateway, que permitirá que nossa rede se comunique com a internet, e o associaremos com a route table:
+ No menu "Internet Gateways", clique no botão "Create internet gateway"
+ Dê um nome para o internet gateway e clique no botão "Create internet gateway"
+ Clique no botão "Actions" e selecione a opção "Attach to VPC"
+ Selecione a VPC adequada e confirme
+ De volta no menu "Route Tables", selecione a route table criada anteriormente e clique na aba "Routes"
+ Clique no botão "Edit routes", faça a configuração como na imagem abaixo e clique em "Save changes"

![imagem_2023-07-09_203620238](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/e93a377d-fe85-4e34-bb9b-01d3f887e3bf)

### Instâncias EC2

A instância servidor deve possuir as seguintes configurações:
+ Sistema operacional Amazon Linux 2
+ 16 GB SSD
+ Família t2.micro ou t3.micro
+ Selecionar a VPC e o security group criados anteriormente

![Configs1](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/4f9c372e-81ed-4c5a-b71e-2afc574a04e2)

A configuração de key pair da instância servidor é mais específica do que a cliente. Teremos que utilizar um key pair que permita o acesso 
ao ambiente da instância por meio de uma chave pública. Para isso, abra o shell CLI do seu sistema operacional(no Windows é o prompt de comando),
digite o comando `ssh-keygen -t rsa -b 2048`. Serão feitas algumas perguntas com relação ao local de instalação das chaves e senhas de acesso,
mas você pode simplesmente pressionar Enter em todos os questionamentos para seguir com os valores padrão.

Com isso, serão geradas uma chave OpenSSH pública e uma privada. Com elas em mãos, siga os seguintes passos:

+ Volte para o menu do serviço EC2 e clique na ferramenta "key pairs"
+ Clique em "Actions" e selecione a opção "Import key pair"
+ Dê um nome ao key pair, faça upload do arquivo da chave pública(ou simplesmente copie o seu conteúdo na caixa de input) e confirme.

![imagem_2023-07-12_111627038](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/de1128f8-ae43-4a90-923a-688dc9a3f1e5)

Feito isso, você terá criado um novo key pair para utilizar na criação de instâncias e, pelo fato da key pública poder estar presente tanto na máquina 
que acessa quanto na máquina que é acessada(instância servidor), será possível fazer o acesso de forma automática, como no exemplo abaixo:

![imagem_2023-07-12_112225270](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/8e4b85b4-fb85-477e-93e8-c80ba8746719)


Também é necessário gerar um elastic IP e anexá-lo à instância, de forma que seu IP não se altere caso a máquina seja desligada ou reiniciada.
Para gerar um elastic IP, é preciso:
+ Selecionar a opção "Elastic IPs" no menu do serviço EC2
+ Clicar no botão "Allocate Elastic IP address"
+ Clicar no botão "Allocate"
+ (Opcional) É possível adicionar tags e fazer configurações relacionadas às AZs
![imagem_2023-07-09_185604550](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/297df41f-0be1-4b97-a789-b8d30df91cd3)

Feito tudo isso, o Elastic IP estará criado, bastando agora apenas anexá-lo à instância servidor. Para isso, é preciso selecionar o Elastic IP criado, clicar em "Actions" e
selecionar a opção "Associate Elastic IP address". Feito isso, uma nova página será aberta, e nela deve-se selecionar a opção "Instance", procurar a instância servidor
e seu respectivo endereço de IP privado. Feitas todas essas configurações, será possível, enfim, clicar no botão "Associate" e associar o Elastic IP à instância.

![imagem_2023-07-09_190606782](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/f7c216a2-4c10-4229-a5aa-bc174e605efd)

Agora, para criar a instância cliente, basta apenas:
+ Sistema operacional Amazon Linux 2
+ 8 GB SSD
+ Família t2.micro ou t3.micro
+ Selecionar a VPC e o security group criados anteriormente

## Configurações do Linux

### Apache

O Apache tem uma instalação e configuração bastante simples. Antes de qualquer coisa, seria interessante que se fizesse todo a configuração no Linux como usuário root, e você pode fazer isso
com o comando `sudo su -`. Mas, caso isso não seja possível, use o `sudo` antes de qualquer comando listado nas próximas etapas do projeto.

Update no sistema antes da instalação:
```
sudo yum update
```
Para realizar a instalação do Apache:
```
sudo yum install httpd
```
Para iniciar o serviço do Apache:
```
sudo systemctl start httpd
```
Para fazer o serviço do Apache iniciar com o boot do sistema:
```
sudo systemctl enable httpd
```
Caso queira verificar o status do serviço e algumas outras informações, use o comando abaixo:
```
sudo systemctl status httpd
```

Agora, é preciso configurar o web server por meio do arquivo httpd.conf, localizado em `/etc/httpd/conf/httpd.conf`. Ao abri-lo no editor de texto com o comando `sudo nano /etc/httpd/conf/httpd.conf` (use
o editor de texto de sua preferência, o comando anterior é apenas um exemplo), ele provavelmente se parecerá com isso:

![imagem_2023-07-11_092621351](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/abc3f79d-6260-45d2-9d22-e1905dd339b9)

Aqui, temos que garantir que algumas coisas estejam configuradas exatamente como desejamos. Na imagem acima, por exemplo, é possível perceber que o servidor Apache estará "ouvindo" na porta 80, que é a porta
padrão do protocolo HTTP. Essa configuração é essencial para que o Apache funcione, afinal, ele se utiliza do protocolo citado anteriormente. 

As outras configurações importantes para o projeto, como o `DocumentRoot`, geralmente já estão corretas por padrão, então isso não deveria ser uma preocupação. Porém, caso algum problema ocorra,verifique se 
os valores no seu documento correspondem ao documento `httpd.conf` presente neste repositório.

Feitas todas as configurações, copie o endereço IPv4 público da sua instância servidor, cole na barra de busca do seu navegador e pressione Enter. Caso você não tenha adicionado nenhum arquivo HTML no diretório
`/var/www/html`, a seguinte página deveria estar sendo exibida:

![imagem_2023-07-11_100623161](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/62e1abbe-25a1-4ef6-bba1-5b5f541dfdff)

### Script

O script é o carro-chefe do projeto. Ele foi programado na linguagem de script Shell e sua função é basicamente criar arquivos de log do Apache e enviá-los para um diretório no NFS. Para criar um arquivo de script, é importante
se atentar a 3 pontos:
+ O uso da extensão `.sh` no fim do nome do arquivo
+ O uso da linha `#!/bin/sh`, que diz para o sistema que o arquivo deve ser executado pelo interpretador de comandos Bash
+ A alteração das permissões de execução do arquivo pelo comando `chmod +x arquivo.sh`, que permitirá que todos possam executar o arquivo

O modo de criar o arquivo será como o exemplo a seguir:
```
touch exemplo.sh
```

O arquivo do script está disponível neste repositório e seu conteúdo é algo próximo disso:
```shell
#!/bin/bash

# Este é o script que criará os arquivos de log do Apache

systemctl status httpd | grep -i active > /efs/seuNome/status.txt
DATE=$(date +"%d-%m-%Y--%T")

if cat /efs/seuNome/status.txt | grep -q "running"; then
        touch $DATE--Apache--RUNNING
        echo "O Apache está rodando!" > $DATE--Apache--RUNNING
        mv $DATE--Apache--RUNNING /efs/seuNome/logs/
        exit 0

elif cat /efs/seuNome/status.txt | grep -q "dead"; then
        touch $DATE--Apache--DEAD
        echo "O Apache não está rodando!" > $DATE--Apache--DEAD
        mv $DATE--Apache--DEAD /efs/seuNome/logs/
        exit 0
fi
```

Agora, com o script pronto para ser executado, vamos configurar o arquivo `/etc/crontab`(arquivo que será lido pelo programa chamado cron, responsável por agendar execuções de tarefas em segundo plano automaticamente)
para fazer com que o script seja executado a cada 5 minutos. Faça essa edição do arquivo com o editor de texto que preferir(nano, vim, vi, etc).

Dentro do arquivo `crontab`, faça a seguinte configuração:

![imagem_2023-07-11_113247831](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/2804e6cc-d003-4db1-bb15-886dae32b3da)

A última linha do arquivo faz com que o usuário root execute o arquivo.sh a cada 5 minutos.

### Servidor NFS

A implementação do NFS será feita por meio do serviço Elastic File System(EFS) da AWS. Por mais que algumas coisas sejam feitas via AWS aqui, preferi colocar essa etapa na parte de linux por ser necessário usar comandos no terminal.

Para criar um file system, devemos:

+ No menu do serviço EFS, clicar em "Create file system"
+ Dê um nome a ele, selecione a VPC criada anteriormente e confirme
+ Com o file system criado, clique em "Attach"
+ selecione a opção "Mount via IP" e copie o comando que lhe for exibido. Ele será parecido com esse:
```
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 192.168.1.227:/ efs
```

Agora no linux, você deve criar um diretório chamado "efs" no diretório /. Ele será o ponto de montagem do sistema de arquivos. Tendo criado o diretório, cole o comando copiado anteriormente, adicione uma / logo antes da palavra "efs" que aparece no
final do comando e pressione Enter. Isso deveria bastar para fazer com que o file system já esteja funcionando dentro do diretório.

Basta agora criar um diretório com seu nome dentro do file system e, dentro do diretório com seu nome, um outro diretório chamado "logs" e um arquivo chamado "status.txt", desse jeito aqui:

![imagem_2023-07-11_123245007](https://github.com/Robert-Marley/atividadeslinuxrepo/assets/85034379/cd2f9150-fdb8-497a-8389-0420cfb6c2d2)

Esses diretórios e arquivos são utilizados no nosso script para armazenar os logs ou fazer a checagem do status do Apache, daí a importância de criá-los.

Por fim, você pode utilizar a máquina cliente para testar o compartilhamento dos arquivos. Para isso, crie também um diretório "efs" no mesmo local e use o mesmo comando que você utilizou anteriormente para montar o file system. Tendo feito
isso, deveria ser possível visualizar os arquivos criados pela instância servidor.
