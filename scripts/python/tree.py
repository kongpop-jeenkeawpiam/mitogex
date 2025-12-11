from ete3 import Tree, TreeStyle, TextFace, NodeStyle
import sys

mitogex_path = sys.argv[1]
contree_path = sys.argv[2]

# 1. Load your tree file (Replace with your actual IQ-TREE output file path)
# IQ-TREE usually creates a file ending in .treefile or .contree
t = Tree(contree_path)

# 2. Define a function to style the nodes (show bootstrap)
def my_layout(node):
    if node.is_leaf():
        # Style leaf names (Sample IDs)
        name_face = TextFace(node.name, fsize=12, fgcolor="black")
        node.add_face(name_face, column=0, position="branch-right")
    else:
        # Style internal nodes (Bootstrap values)
        # IQ-TREE usually stores bootstrap in node.support
        if node.support:
            # Only show support if it's not the root (optional filter > 50)
            if node.support >= 50: 
                support_face = TextFace(f"{int(node.support)}", fsize=10, fgcolor="red")
                node.add_face(support_face, column=0, position="branch-top")

# 3. Setup the Tree Style
ts = TreeStyle()
ts.show_leaf_name = False  # We add names manually in layout for better control
ts.layout_fn = my_layout
ts.show_branch_length = False
ts.show_scale = True
# 4. Render the image
# You can save as .png, .pdf, or .svg (better for papers)
t.render(mitogex_path+"tree.svg", w=300, units="mm", tree_style=ts)
print("Tree image generated: tree.png")
