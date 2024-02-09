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
$musisys->listarEdicao();
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