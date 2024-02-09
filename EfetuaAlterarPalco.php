<html>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link rel='stylesheet' href='style.css'>
<head><title>Musisys - Listar Edicao</title>
</head>
<body background=#ffffff>
<center>
<?php
require('Musisys.php');

$musisys = new Edicao;
$musisys->Edicao();
$musisys->alterarParticipanteDoPalco($_POST["numPalcoNovo"], $_POST["partCod"], $_POST["edicao"]);
$musisys->fecharBDEdicao();

?>
<br> <br> <br> <br> <br> <br> <br> <br>
<h2>Palco alterado com sucesso :D</h2>
<div class="voltar">
    <form action="MenuMusisys.html" method="post">
        <input type="submit" name="Submit" value="voltar ao menu">
    </form>
    
    <form action="ListarEdicao.php" method="post">
        <input type="submit" name="Submit" value="página anterior">
    </form>
</div>
</center>
</body>
</html>