<?php

class MusisysBD {
    /**variavel que guarda a ligação à BD*/
    var $conn;

    /**Função para ligar à BD da MUSISYS   
    @return Um valor indicando qual o resultado da ligação à base de dados.*/
    function ligarBD() {
        $this->conn = mysqli_connect("localhost", "root", "", "musisys_db");
        if(!$this->conn){
          return -1;
        }
    }
   
   /**Executa um determinado comando SQL, retornando o seu resultado.  
   @param sql_command Comando SQL a ser executado pela função
   @return O resultado do comando SQL.*/
    function executarSQL($sql_command) {
        $resultado = mysqli_query( $this->conn, $sql_command);
        return $resultado;
    }
   
   /**Devolve o número de registos de uma determinada tabela numa base de dados
   @param tabela O nome da tabela onde se deseja verificar o numero de registos.
   @return O numero de registos da tabela.*/
    function numero_tuplos($tabela) {
        $tuplos=0;
        $rs=$this->executarSQL("SELECT * FROM $tabela");
        return mysqli_num_rows($rs);  
    }
   
   /**Fecha a ligação à base de dados*/
    function fecharBD() {
        mysqli_close($this->conn);
    }
}

class Edicao extends MusisysBD {

    //Esta variável da classe é responsável pelas operações directas na Base de dados.
    var $bd_musisys;

    //fechar a base de dados
    function fecharBDEdicao() {
        $this->bd_musisys->fecharBD();
    }

    //Inicializa ass edicoes, e as variáveis da classe.
    function Edicao() {
        $this->bd_musisys = new MusisysBD;
        $this->bd_musisys->ligarBD(); 
    }

    //Nova edicao na BD
    function novaEdicao($edicao ,$nome ,$localidade ,$local ,$data_inicio ,$data_fim , $lotacao){
        $sql1 = "INSERT INTO Edicao VALUES($edicao ,'$nome' ,'$localidade' ,'$local' , '$data_inicio' ,'$data_fim' , $lotacao) ";
        $sql2 = "CALL criarDias_festival($edicao, '{$data_inicio}', '{$data_fim}');";
        $this->bd_musisys->executarSQL($sql1);
        $this->bd_musisys->executarSQL($sql2);
    }

    //listar a BD
    function listarEdicao() {
        echo "<link rel='stylesheet' href='style.css'>\n";
        echo "<table class='styled-table'>\n";
        echo " <h1>MUSISYS</h1>\n ";
        echo "       
        <th>Edicao</th>
        <th>Nome</th>
        <th>Localidade</th>
        <th>Local</th>
        <th>Data Inicio</th>
        <th>Data Fim</th>
        <th>Lotacao</th>
        <th>Info</th>
      ";
        $result_set = $this->bd_musisys->executarSQL("SELECT * FROM Edicao");
        $tuplos = mysqli_num_rows($result_set);
        if ($tuplos > 0) {
            for($registo=0; $registo < $tuplos; $registo++) {
                $row = mysqli_fetch_assoc($result_set);
                $this->escreveEdicao($row["numero"] ,$row["nome"] ,$row["localidade"],$row["local"] ,$row["data_inicio"] ,$row["data_fim"] , $row["lotacao"]);
            }
        
         echo "</table>\n";
         echo "</div>\n";
        }
        else {
            echo "<p style='color: white;'>Não foram encontrados resultados</p>";
        }
    }

    function escreveEdicao($edicao, $nome, $localidade, $local, $data_inicio, $data_fim, $lotacao) {
        printf("
        <head>
            <meta charset='UTF-8'>
        </head>
            <tr align=center>
                <td>$edicao</td>
                <td>$nome</td>
                <td>$localidade</td>
                <td>$local</td>
                <td>$data_inicio</td>
                <td>$data_fim</td>
                <td>$lotacao</td>
                <td>    
                    
                <div style='display: flex; justify-content: center; align-items: center;'>
                <form action=\"ListarPalcos.php\" method=post style='margin: 10px 1 10px 0;'>
                    <input type=hidden name=numero value=$edicao>
                    <input type=submit value=Palcos>
                </form>
                <form action=\"ListarParticipantes.php\" method=post style='margin: 10px 1 10px 0;'>
                    <input type=hidden name=numero value=$edicao>
                    <input type=submit value=Participantes>
                </form>
            </div>
                </td>
            </tr>
        ");
    }

    function apagarParticipante($codigo){
        $sql1 = "DELETE FROM tema WHERE Participante_codigo = $codigo";
        $sql2 = "DELETE FROM contrata WHERE Participante_codigo_ = $codigo";
        $this->bd_musisys->executarSQL($sql1);
        $this->bd_musisys->executarSQL($sql2);
    }

    function alterarParticipanteDoPalco($palco,$partcodigo,$edicao){
        $sql2 = "UPDATE contrata SET Palco_codigo = $palco WHERE Participante_codigo_ = $partcodigo AND Edicao_numero_ = $edicao";
        $this->bd_musisys->executarSQL($sql2);
    }



    function listarParticipante($num_edicao) {
        echo "<link rel='stylesheet' href='style.css'>\n";
        echo "<table class='styled-table'>\n";
        echo "       
        <th>Edição</th>
        <th>Código</th>
        <th>Nome</th>
        <th>Código do palco</th>
        <th>Opções</th>
      ";
        $result_set = $this->bd_musisys->executarSQL("SELECT c.Edicao_numero_, p.codigo, p.nome , c.Palco_codigo FROM Participante p, contrata c WHERE p.codigo = c.Participante_codigo_ AND c.Edicao_numero_ = $num_edicao");
        $tuplos = mysqli_num_rows($result_set);
        if ($tuplos > 0) {
            for($registo=0; $registo < $tuplos; $registo++) {
                $row = mysqli_fetch_assoc($result_set);
                $this->escreveParticipante($row["Edicao_numero_"] ,$row["codigo"] , $row["nome"], $row["Palco_codigo"]);
            }
            echo "</table>\n";
            echo "</div>\n";
        }
        else {
            echo "<p style='color: white;'>Não foram encontrados resultados</p>";
        }
    }

    function escreveParticipante($edicao_num ,$codigo ,$nome, $palco) {

        printf("
        <head>
            <meta charset='UTF-8'>
        </head>
            <tr align=center>
                <td>$edicao_num</td>
                <td>$codigo</td>
                <td>$nome</td>
                <td>$palco</td>
                <td>    
                    
                <div style='display: flex; justify-content: center; align-items: center;'>
                <form action=\"AlterarPalco.php\" method=post style='margin: 1px 20 1px -20;' >
                    <input type=hidden name=edicao value=$edicao_num>
                    <input type=hidden name=partNum value=$codigo>
                    <input type=hidden name=palcoNum value=$palco>
                    <input type=submit value=Alterar Palcos>
                </form>
                <form action=\"ApagarParticipante.php\" method=post style='margin: 1px -20 1px 0;' >
                    <input type=hidden name=numero value=$codigo>
                    <input type=submit value=Apagar>
                </form>
            </div>
                </td>
            </tr>
        ");
    }

    function listarPalco($num_edicao) {
        echo "<link rel='stylesheet' href='style.css'>\n";
        echo "<table class='styled-table'>\n";
        echo " <h1>MUSISYS</h1>\n ";
        echo "       
        <th>Edição</th>
        <th>código</th>
        <th>nome</th>
      ";
        $result_set = $this->bd_musisys->executarSQL("SELECT * FROM Palco where Edicao_numero = $num_edicao");
        $tuplos = mysqli_num_rows($result_set);
        if ($tuplos > 0) {
            for($registo=0; $registo < $tuplos; $registo++) {
                echo "<tr>\n";
                $row = mysqli_fetch_assoc($result_set);
                $this->escrevePalco($row["Edicao_numero"] ,$row["codigo"] , $row["nome"]);
                echo "</tr>\n";    
            }
        echo "</table>\n";
        }
        else {
            echo "<p style='color: white;'>Não foram encontrados resultados</p>";
        }
        echo '</div>';
    }

    function escrevePalco($edicao_num ,$codigo ,$nome) {
        printf("
        <head>
            <meta charset='UTF-8'>
        </head>
            <tr align=center>
                <td>$edicao_num</td>
                <td>$codigo</td>
                <td>$nome</td>
            </div>
                </td>
            </tr>
        ");
    }

    function devolveParticipante($participante) {
        $sql="SELECT codigo FROM participante WHERE codigo=$participante";
        $result_set = $this->bd_musisys->executarSQL($sql);
        $row = mysqli_fetch_assoc($result_set);
        return $row["codigo"];
    }


}

class ParticipanteBD extends MusisysBD{

    //Esta variável da classe é responsável pelas operações directas na Base de dados.
    var $bd_musisys_participante;

    //fechar a base de dados
    function fecharBDParticipante() {
        $this->bd_musisys_participante->fecharBD();
    }
    
    //Inicializa ass edicoes, e as variáveis da classe.
    function ParticipanteBD() {
        $this->bd_musisys_participante = new ParticipanteBD;
        $this->bd_musisys_participante->ligarBD(); 
    }

    //listar a BD
    function listarParticipante() {
        echo "<link rel='stylesheet' href='style.css'>\n";
        echo "<table class='styled-table'>\n";
        echo " <h1>MUSISYS</h1>\n ";
        echo "       
        <th>Edição</th>
        <th>Código</th>
        <th>Nome</th>
      ";
        $result_set = $this->bd_musisys_participante->executarSQL("SELECT * FROM Participante");
        $tuplos = mysqli_num_rows($result_set);
        if ($tuplos > 0) {
            for($registo=0; $registo < $tuplos; $registo++) {
                echo "<tr>\n";
                $row = mysqli_fetch_assoc($result_set);
                $this->escreveParticipanteBasico($row["edicao_num"] ,$row["codigo"] , $row["nome"]);
                echo "</tr>\n";    
            }
        echo "</table>\n";
        }
        else {
            echo "<p style='color: white;'>Não foram encontrados resultados</p>";
        }
    }
    
    function escreveParticipanteBasico($edicao_num,$codigo,$nome) {
        printf("
        <head>
            <meta charset='UTF-8'>
        </head>
            <tr align=center>
                <td>$edicao_num</td>
                <td>$codigo</td>
                <td>$nome</td>
            </div>
                </td>
            </tr>
        ");
    }

    function pesquisarParticipanteBasico($filtro) {
        echo "<link rel='stylesheet' href='style.css'>\n";
        echo "<table class='styled-table'>\n";
        echo " <h1>MUSISYS</h1>\n ";
        echo "       
        <th>Edição</th>
        <th>Código</th>
        <th>Nome</th>
      ";
        $result_set = $this->bd_musisys_participante->executarSQL("SELECT * FROM participante WHERE codigo LIKE '%$filtro%' ");
        $n_r =0;
        echo "";
        while($row = mysqli_fetch_assoc($result_set)){
          $n_r =1;
          echo "<tr>\n";
          $this->escreveParticipanteBasico($row["edicao_num"], $row["codigo"],$row["nome"]);
          echo "</tr>\n";    
        }
        echo "</table>\n";
        if($n_r ==0)
            echo "nao foram encontrados participantes";

        echo '</div>';
    }

    function pesquisarParticipanteAvancado($filtro1 ,$filtro2) {
        echo "<link rel='stylesheet' href='style.css'>\n";
        echo "<table class='styled-table'>\n";
        echo " <h1>MUSISYS</h1>\n ";
        echo "       
        <th>Edição</th>
        <th>Código</th>
        <th>Nome</th>
      ";
        $result_set = $this->bd_musisys_participante->executarSQL("SELECT c.Edicao_numero_, p.codigo, p.nome, c.Palco_codigo 
        FROM Participante p 
        JOIN contrata c ON p.codigo = c.Participante_codigo_ AND c.Palco_codigo = $filtro1
        JOIN entrevista e ON p.codigo = e.Participante_codigo_
        GROUP BY p.codigo, c.Edicao_numero_, p.nome, c.Palco_codigo 
        HAVING COUNT(e.Participante_codigo_) > $filtro2;
        "); 
        $n_r =0;
        echo "";
        while($row = mysqli_fetch_assoc($result_set)){
          $n_r =1;
          echo "<tr>\n";  
          $this->escreveParticipanteBasico($row["Edicao_numero_"], $row["codigo"],$row["nome"]);
          echo "</tr>\n";    
        }
        echo "</table>\n";
        if($n_r ==0)
            echo "<p style='color: white;'>Não foram encontrados participantes</p>";

        echo '</div>';
    }

}