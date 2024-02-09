<html>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link rel='stylesheet' href='style.css'>
<head><title>Musisys - PesquisarParticipante</title>
</head>
<body background=#ffffff>
<center>
<?php
require('Musisys.php');

$musisys = new ParticipanteBD;
$musisys->ParticipanteBD();
$musisys->pesquisarParticipanteBasico($_POST["codigoPesquisa"]);
$musisys->fecharBDParticipante();

?>
<br>
<div class="voltar">
    <form action="MenuMusisys.html" method="post">
        <input type="submit" name="Submit" value="voltar ao menu">
    </form>
</div>
</center>
</body>
</html>