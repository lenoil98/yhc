def main():
    build("Database.hs")
    build("Basics.hs")
    build("Vector.hs")
    build("Matrix.hs")
    build("VBmatrix.hs")
    build("VBlldecomp.hs")
    build("DB_interface.hs")
    build("Degrees.hs")
    build("Pre_assemble.hs")
    build("Elemstif.hs")
    build("Assemble_stiffness.hs")
    build("Assemble_loadvec.hs")
    build("Displacement.hs")
    build("Elemforce.hs")
    build("PrintSource.hs")
    build("Printuvwforce.hs")
    build("Main.hs")
    run("Main")
