from argparse import ArgumentParser
from nltk.tokenize import word_tokenize


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--input')
    parser.add_argument('--save_texts_to')
    parser.add_argument('--save_labels_to')
    parser.add_argument('--save_document_ids_to')
    args = parser.parse_args()

    with open(args.input, encoding='utf-8') as input_stream:
        tokens = [word_tokenize(line.strip()) for line in input_stream]
    labels = [['O']*len(token_seq) for token_seq in tokens]


    with open(args.save_texts_to, 'w', encoding='utf-8') as tokens_output_stream, \
          open(args.save_labels_to, 'w', encoding='utf-8') as labels_output_stream, \
          open(args.save_document_ids_to, 'w', encoding='utf-8') as document_ids_output_stream:
        for document_id, (token_seq, label_seq) in enumerate(zip(tokens, labels)):
            tokens_output_stream.write(' '.join(token_seq) + '\n')
            labels_output_stream.write(' '.join(label_seq) + '\n')
            document_ids_output_stream.write("{}".format(document_id) + '\n')
