
$JAVA -Xmx64G -jar $CLUSTERPICKER $OUT_DIR/fasta/$JOINT_NAME/$JOINT_NAME.95X.variable.IncComplex.5SNPcluster.fa $OUT_DIR/phylogeny/$JOINT_NAME/$JOINT_NAME.95X.IncComplex.5SNPcluster.treefile 0 0 $FRACTION1  0 gap


$JAVA -Xmx64G -jar $CLUSTERPICKER $OUT_DIR/fasta/$JOINT_NAME/$JOINT_NAME.95X.variable.IncComplex.12SNPcluster.fa $OUT_DIR/phylogeny/$JOINT_NAME/$JOINT_NAME.95X.IncComplex.12SNPcluster.treefile 0 0 $FRACTION2  0 gap
