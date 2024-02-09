<html>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link rel='stylesheet' href='style.css'>
<head><title>Musisys - Listar Palcos e artistas</title>
</head>
<body background=#ffffff>
<center>
<?php
require('Musisys.php');

$musisys = new Edicao;
$musisys->Edicao();
$musisys->listarPalco($_POST["numero"]);
$musisys->fecharBDEdicao();

?>
<br>
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