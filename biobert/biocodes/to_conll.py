from argparse import ArgumentParser


def map_label(label):
  if label == 'O': return label
  return label + '-COND'


if __name__ == '__main__':
  parser = ArgumentParser()
  parser.add_argument('--predicted')
  parser.add_argument('--gold')
  parser.add_argument('--save_to')
  args = parser.parse_args()

  with open(args.predicted) as predicted_input_stream, \
   open(args.gold) as gold_input_stream, \
   open(args.save_to, 'w') as output_stream:
    for predicted_line, gold_line in zip(predicted_input_stream, gold_input_stream):
      predicted_line = predicted_line.strip()
      gold_line = gold_line.strip()
      # print(predicted_line, '\t|\t', gold_line)
      if predicted_line == '' or gold_line == '':
        output_stream.write('\n')
        continue
      predicted_token, predicted_label = predicted_line.split('\t')
      gold_token, gold_label = gold_line.split()
      # predicted_label = map_label(predicted_label)
      # gold_label = map_label(gold_label)
      if predicted_token != gold_token: print("{}\t|\t{}".format(predicted_token, gold_token))
      output_stream.write('{} {} {}\n'.format(gold_token, gold_label, predicted_label))
