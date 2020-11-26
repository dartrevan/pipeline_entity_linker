INPUT_DATA_DIR=/data
NER_MODEL_DIR=models/ner_model
NORMALIZATION_MODEL_DIR=models/normalization_model
OUTPUT_DIR=/data
WORKING_DIR=/tmp/workdir
PROJECT_DIR=/root/pipeline_entity_linker

mkdir -p $WORKING_DIR/vocabs
# convert input into plain format
# staff
python $PROJECT_DIR/data_processing_utils/to_plain.py --input $INPUT_DATA_DIR/texts.txt --save_texts_to $WORKING_DIR/test_texts.txt \
                                                      --save_labels_to $WORKING_DIR/test_labels.txt --save_document_ids_to $WORKING_DIR/test_document_ids.txt

cp $WORKING_DIR/test_labels.txt $WORKING_DIR/train_labels.txt
cp $WORKING_DIR/test_texts.txt $WORKING_DIR/train_texts.txt
cp $WORKING_DIR/test_labels.txt $WORKING_DIR/test_gazetteers.txt
cp $WORKING_DIR/test_labels.txt $WORKING_DIR/train_gazetteers.txt
cp $NER_MODEL_DIR/label2id.pkl $WORKING_DIR
cp $NER_MODEL_DIR/tagset.txt $WORKING_DIR
cp $NORMALIZATION_MODEL_DIR/labels_vocab.txt $WORKING_DIR/vocabs/vocab.txt

CUDA_VISIBLE_DEVICES=0 python $PROJECT_DIR/biobert/run_ner.py --do_eval=False --do_train=False --do_predict=True --vocab_file=$NER_MODEL_DIR/vocab.txt --bert_config_file=$NER_MODEL_DIR/bert_config.json \
      --init_checkpoint=$NER_MODEL_DIR/model.ckpt-8415 \
      --num_train_epochs 50.0  --data_dir=$WORKING_DIR  \
      --output_dir=$WORKING_DIR  \
      --save_checkpoints_steps 5000 \
      --max_seq_length 128 \
      --do_lower_case=True

python $PROJECT_DIR/biobert/biocodes/detok.py --tokens $WORKING_DIR/token_test.txt --labels $WORKING_DIR/label_test.txt  --save_to $WORKING_DIR/predicted_biobert.txt
python $PROJECT_DIR/data_processing_utils/extract_entities.py --conll_data $WORKING_DIR/predicted_biobert.txt --save_entities_to $WORKING_DIR/test_norm_entities.txt

# extract entities from conll
# staff

CUDA_VISIBLE_DEVICES=0 python $PROJECT_DIR/biobert/run_classifier.py --do_eval=False --do_train=False --do_predict=True --vocab_file=$NORMALIZATION_MODEL_DIR/vocab.txt --bert_config_file=$NORMALIZATION_MODEL_DIR/bert_config.json \
      --init_checkpoint=$NORMALIZATION_MODEL_DIR/model.ckpt \
      --num_train_epochs 50.0  --data_dir=$WORKING_DIR  \
      --output_dir=$WORKING_DIR  \
      --save_checkpoints_steps 5000 \
      --max_seq_length 128 \
      --do_lower_case=True

python $PROJECT_DIR/data_processing_utils/collect_results.py --conll_data $WORKING_DIR/predicted_biobert.txt --concept_ids $WORKING_DIR/test_results.tsv --save_to $OUTPUT_DIR/results.json
rm -rf $WORKING_DIR
# combine ner and normalization and store in json

