import pandas as pd
import sys
import os

def process_annovar(input_file):
    df = pd.read_csv(input_file, sep='\t', low_memory=False)

    # Identify the VCF columns added by -otherinfo
    # Usually: ... [annotations] | CHROM | POS | ID | REF | ALT | QUAL | FILTER | INFO | FORMAT | SAMPLE
    # The SAMPLE column is the very last one (-1)
    # The FORMAT column defines the order (-2)
    sample_col = df.columns[-1]
    format_col = df.columns[-2]
    filter_col = df.columns[-4]  # The VCF 'FILTER' column (4th from the end)

    def get_af(row):
        try:
            fmt_keys = str(row[format_col]).split(':')
            sample_vals = str(row[sample_col]).split(':')
            af_idx = fmt_keys.index('AF')  # Find where AF is located
            return sample_vals[af_idx]
        except (ValueError, IndexError):
            return "."

    df.insert(5, 'HeteroplasmyLevels', df.apply(get_af, axis=1))

    df.rename(columns={filter_col: 'VCF_Filter'}, inplace=True)

    # Save the updated file
    output_name = input_file.replace('.txt', '_clean.txt')
    df.to_csv(output_name, sep='\t', index=False)
    print(f"Success! Cleaned file saved as: {output_name}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python extract_heteroplasmy.py <your_file.hg38_multianno.txt>")
    else:
        process_annovar(sys.argv[1])
