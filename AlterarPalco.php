<html>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link rel='stylesheet' href='style.css'>

<head><title>Musisys - Listar Participantes</title>
</head>
<h1>MUSISYS</h1>
<?php
$edicao = $_POST["edicao"];
$partNum = $_POST["partNum"];
?>
<div class="section">
        <center>
        <h2>Alterar Palco para:</h2>
        </center>
        <form method="post" action="EfetuaAlterarPalco.php">
            <label for="numPalcoNovo">Número do Palco:</label>
            <input type="number" name="numPalcoNovo" required>
            <input type="hidden" name="edicao" value="<?php echo $edicao; ?>">
            <input type="hidden" name="partCod" value="<?php echo $partNum; ?>">
        <center>
            <input type="submit" name="Submit" value="Alterar">
        </center>
        
    </div>

    <br>
<center>
<div class="voltar">
    <form action="MenuMusisys.html" method="post">
    <input type="submit" name="Submit" value="voltar ao menu">
</div>
</center>
</html>