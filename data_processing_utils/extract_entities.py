from argparse import ArgumentParser
from NLPDatasetIO.dataset import Dataset


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--conll_data')
    parser.add_argument('--save_entities_to')
    args = parser.parse_args()
    dataset = Dataset(location=args.conll_data, format='conll', sep=' ')
    with open(args.save_entities_to, 'w', encoding='utf-8') as output_stream:
        for document in dataset.documents:
            for entity in document.entities:
                output_stream.write(f"{entity.text}\n")
