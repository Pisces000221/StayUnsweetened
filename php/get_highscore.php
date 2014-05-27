<?php
    // This is used to get high scores.
    // Use like get_highscore.php
    // Outputs a file containing top 30 players.

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
                $t = $record[$i];
                $record[$i] = $record[$j];
                $record[$j] = $t;
            }
    // Output
    printf("return {\n");
    $output_ct = 30;
    if ($tot < $output_ct) $output_ct = $tot;
    for ($i = 0; $i < $output_ct; $i++)
        printf('    [%d] = { name = \'%s\', machine = \'%s\', wave = %d, score = %d }%s',
            $i + 1, $record[$i]['name'], $record[$i]['machine'],
            $record[$i]['wave'], $record[$i]['score'],
            $i == $output_ct - 1 ? "\n" : ",\n");
    printf("}\n");
?>
