from argparse import ArgumentParser
from NLPDatasetIO.dataset import Dataset


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--conll_data')
    parser.add_argument('--concept_ids')
    parser.add_argument('--save_to')
    args = parser.parse_args()
    dataset = Dataset(location=args.conll_data, format='conll', sep=' ')
    with open(args.concept_ids, encoding='utf-8') as input_stream:
        concept_ids = [line.split()[0] for line in input_stream]

    idx = 0
    for document in dataset.documents:
        for entity in document.entities:
            entity.label = concept_ids[idx]
            idx += 1

    dataset.save('json', path_to_save=args.save_to)
