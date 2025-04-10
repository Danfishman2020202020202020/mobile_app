package com.mbta.tid.mbta_app.android.component.legacyRouteCard

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.mbta.tid.mbta_app.android.component.routeCard.TransitHeader
import com.mbta.tid.mbta_app.android.component.routeIcon
import com.mbta.tid.mbta_app.android.util.fromHex
import com.mbta.tid.mbta_app.model.Line
import com.mbta.tid.mbta_app.model.Route

@Composable
fun LineHeader(
    line: Line,
    routes: List<Route>,
    rightContent: (@Composable (textColor: Color) -> Unit)? = null
) {
    val route = routes.first()
    val (modeIcon, modeDescription) = routeIcon(route = route)
    TransitHeader(
        name = line.longName,
        routeType = route.type,
        backgroundColor = Color.fromHex(line.color),
        textColor = Color.fromHex(line.textColor),
        modeIcon = modeIcon,
        modeDescription = modeDescription,
        rightContent = rightContent
    )
}
