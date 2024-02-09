<html>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link rel='stylesheet' href='style.css'>
<head><title>Musisys - Apagar Participante</title>
</head>
<body background=#ffffff>
<center>
<br>
<br>

<?php
require('Musisys.php');

$musisys = new Edicao;
$musisys->Edicao();
$musisys->apagarParticipante($_POST["numero"]);
$musisys->fecharBDEdicao();

?>
<br> <br> <br> <br> <br> <br> <br> <br>
<p style='color: white;'>O artista cancelou o artista com sucesso</p>
<div class="voltar">
    <form action="MenuMusisys.html" method="post">
        <input type="submit" name="Submit" value="voltar ao menu">
    </form>
    
    <form action="ListarParticipantes.php" method="post">
        <input type="submit" name="Submit" value="página anterior">
    </form>
</div>
</center>
</body>
</html>