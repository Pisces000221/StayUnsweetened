<?php
    // This is used to submit a score.
    // Use like submit_score.php?name=TOM&machine=D08&wave=7&score=133000
    // Outputs a file containing the player's current rank and total players
    // e.g. Output '30 100' means you're the 30th of 100 players

    // Save data first
    $f = fopen('all_scores.dat', 'a');
    //http://stackoverflow.com/questions/470617/get-current-date-and-time-in-php
    fprintf($f, "%s %s %d %d %s\n", $_GET['name'],
        $_GET['machine'], $_GET['wave'], $_GET['score'], date('Y/m/d h:i:s a', time()));
    fclose($f);
    // Read all scores before
    $f = fopen('all_scores.dat', 'r');
    $tot = 0;
    while (($line = fgets($f)) !== false) {
        if ($line == '') continue;
        sscanf($line, '%s%s%d%d', $name, $machine, $wave, $score);
        $record[$tot++] = array('name' => $name, 'machine' => $machine, 'wave' => $wave, 'score' => $score);
    }
    fclose($f);
    // Bubble sort
    for ($i = 0; $i < $tot - 1; $i++)
        for ($j = $i + 1; $j < $tot; $j++)
            if ($record[$i]['score'] < $record[$j]['score']) {
                $t = $record[$i]['score'];
                $record[$i]['score'] = $record[$j]['score'];
                $record[$j]['score'] = $t;
            }
    // Calculate the current rank
    $rank = $tot;
    for ($i = 0; $i < $tot - 1; $i++)
        if ($_GET['score'] == $record[$i]['score']) { $rank = $i + 1; break; }
    printf('%d %d', $rank, $tot);
?>
