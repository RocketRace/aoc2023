val scala3Version = "3.3.1"

lazy val root = project
  .in(file("."))
  .settings(
    name := "23",
    version := "0.1.0-SNAPSHOT",
    scalaVersion := scala3Version,
    libraryDependencies += "org.scala-lang" %% "toolkit" % "0.1.7",
    libraryDependencies += "org.scalameta" %% "munit" % "0.7.29" % Test
  )
