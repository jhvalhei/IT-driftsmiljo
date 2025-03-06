postdb = {
}
rg_dynamic = {
 = {name =  location = westeurope}
TestWebApp = {name = TestWebApp location = westeurope}
}
container = {
 = {name =  image=}
TestWebApp = {name = TestWebApp image=ghcr.io/bachelorgruppe117-ntnu-gjovik/testwebapp-app:latest}
}
postdb = {
}
rg_dynamic = {
	TestWebApp = {name = "TestWebApp" location = "westeurope"}
}
container = {
	TestWebApp = {name = "TestWebApp" image="ghcr.io/bachelorgruppe117-ntnu-gjovik/testwebapp-app:latest"}
}
