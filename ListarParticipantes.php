<html>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link rel='stylesheet' href='style.css'>
<head><title>Musisys - Listar Participantes</title>
</head>
<h1>MUSISYS</h1>
<center>
<?php
require('Musisys.php');

$musisys = new Edicao;
$musisys->Edicao();
$musisys->listarParticipante($_POST["numero"]);
$musisys->fecharBDEdicao();

?>
<br>
<div class="voltar">
    <form action="MenuMusisys.html" method="post">
    <input type="submit" name="Submit" value="voltar ao menu">
</div>
</center>
</body>
</html>