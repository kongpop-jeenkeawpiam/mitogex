from ete4 import Tree
from ete4.treeview import TreeStyle

t = Tree(open('/media/mitogex/mitogex1/MitoGEx/Results/Phylogenetic/50Sample.fasta.contree')) 

t.unroot()
t.show()
# t.render('/media/mitogex/mitogex1/MitoGEx/Results/Phylogenetic/mytree.pdf')


# Create a tree style (optional)
# ts = TreeStyle()
# ts.show_leaf_name = True  # Customize the tree style if needed
# Render the tree as an SVG image
# svg_file = '/media/mitogex/mitogex1/MitoGEx/Results/Phylogenetic/mytree.svg'
# t.render(svg_file, tree_style=ts)

# # Create an HTML file with the embedded SVG
# html_output = '/media/mitogex/mitogex1/MitoGEx/Results/Phylogenetic/mytree.html'
# with open(html_output, 'w') as html_file:
#     html_file.write(f'''
#     <!DOCTYPE html>
#     <html lang="en">
#     <head>
#         <meta charset="UTF-8">
#         <title>Phylogenetic Tree</title>
#     </head>
#     <body>
#         <h1>Phylogenetic Tree</h1>
#         <embed src="{svg_file}" type="image/svg+xml" width="100%" height="600px"/>
#     </body>
#     </html>
#     ''')

# print(f"HTML file created: {html_output}")


# circular_style = TreeStyle()
# circular_style.mode = 'c'  # draw tree in circular mode
# circular_style.scale = 50
# circular_style.arc_start = -180 # 0 degrees = 3 o'clock
# circular_style.arc_span = 180
# t.render('/media/mitogex/mitogex1/MitoGEx/Results/Phylogenetic/mytree.png', w=1920,h=1020, units='px', tree_style=circular_style)
# t.explore(keep_server=True)
