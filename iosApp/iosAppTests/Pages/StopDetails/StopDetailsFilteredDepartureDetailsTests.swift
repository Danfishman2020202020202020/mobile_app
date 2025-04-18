//
//  StopDetailsFilteredDepartureDetailsTests.swift
//  iosAppTests
//
//  Created by esimon on 12/2/24.
//  Copyright © 2024 MBTA. All rights reserved.
//

@testable import iosApp
import Shared
import SwiftUI
import ViewInspector
import XCTest

final class StopDetailsFilteredDepartureDetailsTests: XCTestCase {
    override func setUp() {
        executionTimeAllowance = 60
    }

    func testDisplaysTrips() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route()

        let tile1 = TileData(
            route: route,
            headsign: "A",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .heavyRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let tile2 = TileData(
            route: route,
            headsign: "B",
            formatted: UpcomingFormat.Some(
                trips: [.init(
                    trip: .init(trip: objects.trip { _ in }),
                    routeType: .heavyRail,
                    format: .Minutes(minutes: 3)
                )],
                secondaryAlert: nil
            )
        )
        let tile3 = TileData(
            route: route,
            headsign: "C",
            formatted: UpcomingFormat.Some(
                trips: [.init(
                    trip: .init(trip: objects.trip { _ in }),
                    routeType: .heavyRail,
                    format: .Minutes(minutes: 7)
                )],
                secondaryAlert: nil
            )
        )
        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile1, tile2, tile3],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(route: route, stop: stop, patterns: [], elevatorAlerts: []),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: .init(),
            mapVM: .init(),
            stopDetailsVM: .init(),
            viewportProvider: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertNotNil(try sut.inspect().find(text: "A"))
        XCTAssertNotNil(try sut.inspect().find(text: "ARR"))
        XCTAssertNotNil(try sut.inspect().find(text: "B"))
        XCTAssertNotNil(try sut.inspect().find(text: "3 min"))
        XCTAssertNotNil(try sut.inspect().find(text: "C"))
        XCTAssertNotNil(try sut.inspect().find(text: "7 min"))
    }

    func testHeadsignsHiddenWhenMatching() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route()

        let tile1 = TileData(
            route: route,
            headsign: "Matching",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .heavyRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let tile2 = TileData(
            route: route,
            headsign: tile1.headsign,
            formatted: UpcomingFormat.Some(
                trips: [.init(
                    trip: .init(trip: objects.trip { _ in }),
                    routeType: .heavyRail,
                    format: .Minutes(minutes: 3)
                )],
                secondaryAlert: nil
            )
        )
        let tile3 = TileData(
            route: route,
            headsign: tile1.headsign,
            formatted: UpcomingFormat.Some(
                trips: [.init(
                    trip: .init(trip: objects.trip { _ in }),
                    routeType: .heavyRail,
                    format: .Minutes(minutes: 7)
                )],
                secondaryAlert: nil
            )
        )
        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile1, tile2, tile3],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(route: route, stop: stop, patterns: [], elevatorAlerts: []),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: .init(),
            mapVM: .init(),
            stopDetailsVM: .init(),
            viewportProvider: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertThrowsError(try sut.inspect().find(DepartureTile.self).find(text: tile1.headsign))
        XCTAssertNotNil(try sut.inspect().find(text: "ARR"))
        XCTAssertNotNil(try sut.inspect().find(text: "3 min"))
        XCTAssertNotNil(try sut.inspect().find(text: "7 min"))
    }

    func testAlwaysShowsHeadsignAndPillsWhenLine() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { route in route.id = "Green-B" }
        let line = objects.line { line in line.id = "Green" }

        let tile1 = TileData(
            route: route,
            headsign: "Matching",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .lightRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let tile2 = TileData(
            route: route,
            headsign: tile1.headsign,
            formatted: UpcomingFormat.Some(
                trips: [.init(
                    trip: .init(trip: objects.trip { _ in }),
                    routeType: .lightRail,
                    format: .Minutes(minutes: 3)
                )],
                secondaryAlert: nil
            )
        )
        let tile3 = TileData(
            route: route,
            headsign: tile1.headsign,
            formatted: UpcomingFormat.Some(
                trips: [.init(
                    trip: .init(trip: objects.trip { _ in }),
                    routeType: .lightRail,
                    format: .Minutes(minutes: 7)
                )],
                secondaryAlert: nil
            )
        )
        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile1, tile2, tile3],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(
                routes: [route], line: line, stop: stop,
                patterns: [], directions: [], elevatorAlerts: []
            ),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: .init(),
            mapVM: .init(),
            stopDetailsVM: .init(),
            viewportProvider: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertNotNil(try sut.inspect().find(DepartureTile.self).find(text: tile1.headsign))
        XCTAssertNotNil(try sut.inspect().find(DepartureTile.self).find(RoutePill.self))
        XCTAssertNotNil(try sut.inspect().find(text: "ARR"))
        XCTAssertNotNil(try sut.inspect().find(text: "3 min"))
        XCTAssertNotNil(try sut.inspect().find(text: "7 min"))
    }

    func testShowsTripDetails() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { route in route.id = "Green-B" }
        let pattern = objects.routePattern(route: route) { _ in }
        let line = objects.line { line in line.id = "Green" }
        let trip = objects.trip { trip in
            trip.routeId = route.id
            trip.routePatternId = pattern.id
        }

        let tile1 = TileData(
            route: route,
            headsign: "Matching",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: trip), routeType: .lightRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let tile2 = TileData(
            route: route,
            headsign: tile1.headsign,
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: trip), routeType: .lightRail, format: .Minutes(minutes: 3))],
                secondaryAlert: nil
            )
        )
        let tile3 = TileData(
            route: route,
            headsign: tile1.headsign,
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: trip), routeType: .lightRail, format: .Minutes(minutes: 7))],
                secondaryAlert: nil
            )
        )
        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: .init(tripId: trip.id, vehicleId: nil, stopSequence: nil, selectionLock: false),
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile1, tile2, tile3],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(
                routes: [route], line: line, stop: stop,
                patterns: [], directions: [], elevatorAlerts: []
            ),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: .init(),
            mapVM: .init(),
            stopDetailsVM: .init(),
            viewportProvider: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertNotNil(try sut.inspect().find(TripDetailsView.self))
    }

    func testShowsCancelledTripCard() throws {
        let now = Date.now
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { route in
            route.id = "66"
            route.type = .bus
        }
        let pattern = objects.routePattern(route: route) { _ in }
        let trip = objects.trip(routePattern: pattern)
        let schedule = objects.schedule { schedule in
            schedule.trip = trip
            schedule.departureTime = now.addingTimeInterval(10).toKotlinInstant()
        }
        let prediction = objects.prediction(schedule: schedule) { prediction in
            prediction.trip = trip
            prediction.scheduleRelationship = .cancelled
        }
        let upcoming = objects.upcomingTrip(schedule: schedule, prediction: prediction)

        let tile1 = TileData(
            route: route,
            headsign: "Harvard",
            formatted: UpcomingFormat.Some(
                trips: [.init(
                    trip: upcoming, routeType: .bus,
                    format: .Cancelled(
                        scheduledTime: schedule.departureTime!
                    )
                )],
                secondaryAlert: nil
            )
        )
        let tile2 = TileData(
            route: route,
            headsign: tile1.headsign,
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: trip), routeType: .bus, format: .Minutes(minutes: 3))],
                secondaryAlert: nil
            )
        )
        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: .init(tripId: trip.id, vehicleId: nil, stopSequence: nil, selectionLock: false),
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile1, tile2],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(
                routes: [route],
                line: nil,
                stop: stop,
                patterns: [
                    RealtimePatterns.ByHeadsign(
                        route: route,
                        headsign: "Harvard",
                        line: nil,
                        patterns: [pattern],
                        upcomingTrips: [
                            .init(trip: trip, schedule: schedule, prediction: prediction),
                        ]
                    ),
                ],
                directions: [
                    .init(name: "", destination: "", id: 0),
                    .init(name: "", destination: "", id: 1),
                ],
                elevatorAlerts: []
            ),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: .init(),
            mapVM: .init(),
            stopDetailsVM: .init(),
            viewportProvider: .init()
        ).environmentObject(ViewportProvider())
        XCTAssertNotNil(try sut.inspect().find(text: "Trip cancelled"))
        XCTAssertNotNil(try sut.inspect()
            .find(text: "This trip has been cancelled. We’re sorry for the inconvenience."))
        XCTAssertNotNil(try sut.inspect().find(ViewType.Image.self, where: { image in
            try image.actualImage().name() == "mode-bus-slash"
        }))
    }

    func testShowsNoTripCard() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { route in route.id = "Green-B" }
        let line = objects.line { line in line.id = "Green" }

        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [],
            noPredictionsStatus: UpcomingFormat.NoTripsFormatServiceEndedToday(),
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(
                routes: [route], line: line, stop: stop,
                patterns: [], directions: [], elevatorAlerts: []
            ),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: .init(),
            mapVM: .init(),
            stopDetailsVM: .init(),
            viewportProvider: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertThrowsError(try sut.inspect().find(TripDetailsView.self))
        XCTAssertThrowsError(try sut.inspect().find(DepartureTile.self))
        XCTAssertNotNil(try sut.inspect().find(StopDetailsNoTripCard.self))
    }

    func testShowsSuspension() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { _ in }
        let alert = objects.alert { alert in
            alert.effect = .suspension
            alert.header = "Fuchsia Line suspended from Here to There"
        }

        // in practice any trips should be skipped but for major alerts we want to hide trips if they somehow aren't
        // skipped
        let tile = TileData(
            route: route,
            headsign: "A",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .heavyRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let nearbyVM = NearbyViewModel()

        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile],
            noPredictionsStatus: nil,
            alerts: [alert],
            downstreamAlerts: [],
            patternsByStop: .init(route: route, stop: stop, patterns: [], elevatorAlerts: []),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: nearbyVM,
            mapVM: .init(),
            stopDetailsVM: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertThrowsError(try sut.inspect().find(DepartureTile.self))
        XCTAssertNotNil(try sut.inspect().find(AlertCard.self))
        XCTAssertNotNil(try sut.inspect().find(text: "Suspension"))
        XCTAssertNotNil(try sut.inspect().find(text: alert.header!))
        try sut.inspect().find(button: "View details").tap()
        XCTAssertEqual(
            nearbyVM.navigationStack.last,
            .alertDetails(alertId: alert.id, line: nil, routes: [route], stop: stop)
        )
    }

    func testShowsDownstreamAlert() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { _ in }
        let alert = objects.alert { alert in
            alert.effect = .suspension
            alert.header = "Fuchsia Line suspended from Here to There"
        }

        let tile = TileData(
            route: route,
            headsign: "A",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .heavyRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let nearbyVM = NearbyViewModel()

        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [alert],
            patternsByStop: .init(route: route, stop: stop, patterns: [], elevatorAlerts: []),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: nearbyVM,
            mapVM: .init(),
            stopDetailsVM: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertNotNil(try sut.inspect().find(DepartureTile.self))
        XCTAssertNotNil(try sut.inspect().find(AlertCard.self))
        XCTAssertNotNil(try sut.inspect().find(text: "Service suspended ahead"))
        XCTAssertThrowsError(try sut.inspect().find(text: alert.header!))
        try sut.inspect().find(AlertCard.self).implicitAnyView().button().tap()
        XCTAssertEqual(
            nearbyVM.navigationStack.last,
            .alertDetails(alertId: alert.id, line: nil, routes: [route], stop: stop)
        )
    }

    func testShowsElevatorAlert() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { _ in }
        let alert = objects.alert { alert in
            alert.effect = .elevatorClosure
            alert.header = "Elevator closed at stop"
        }

        let tile = TileData(
            route: route,
            headsign: "A",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .heavyRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let nearbyVM = NearbyViewModel()
        let stopDetailsVM = StopDetailsViewModel()
        stopDetailsVM.showElevatorAccessibility = true

        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(route: route, stop: stop, patterns: [], elevatorAlerts: [alert]),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: nearbyVM,
            mapVM: .init(),
            stopDetailsVM: stopDetailsVM
        ).environmentObject(ViewportProvider())

        XCTAssertNotNil(try sut.inspect().find(DepartureTile.self))
        XCTAssertNotNil(try sut.inspect().find(AlertCard.self))
        XCTAssertNotNil(try sut.inspect().find(text: alert.header!))
        try sut.inspect().find(AlertCard.self).implicitAnyView().button().tap()
        XCTAssertEqual(
            nearbyVM.navigationStack.last,
            .alertDetails(alertId: alert.id, line: nil, routes: nil, stop: stop)
        )
    }

    func testShowsInaccessible() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { stop in
            stop.wheelchairBoarding = .inaccessible
        }
        let route = objects.route { _ in }
        let tile = TileData(
            route: route,
            headsign: "A",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .heavyRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let nearbyVM = NearbyViewModel()
        let stopDetailsVM = StopDetailsViewModel()
        stopDetailsVM.showElevatorAccessibility = true

        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile],
            noPredictionsStatus: nil,
            alerts: [],
            downstreamAlerts: [],
            patternsByStop: .init(route: route, stop: stop, patterns: [], elevatorAlerts: []),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: nearbyVM,
            mapVM: .init(),
            stopDetailsVM: stopDetailsVM
        ).environmentObject(ViewportProvider())

        XCTAssertNotNil(try sut.inspect().find(text: "This stop is not accessible"))
    }

    func testShowsSubwayDelayAlert() throws {
        let objects = ObjectCollectionBuilder()
        let stop = objects.stop { _ in }
        let route = objects.route { _ in }
        let alert = objects.alert { alert in
            alert.effect = .delay
            alert.header = "Delay header"
            alert.cause = .heavyRidership
            alert.severity = 10
            alert.informedEntity(
                activities: [.board, .exit, .ride],
                directionId: 0, facility: nil,
                route: route.id, routeType: .lightRail,
                stop: nil, trip: nil
            )
        }

        let tile = TileData(
            route: route,
            headsign: "A",
            formatted: UpcomingFormat.Some(
                trips: [.init(trip: .init(trip: objects.trip { _ in }), routeType: .heavyRail, format: .Arriving())],
                secondaryAlert: nil
            )
        )
        let nearbyVM = NearbyViewModel()

        let sut = StopDetailsFilteredDepartureDetails(
            stopId: stop.id,
            stopFilter: .init(routeId: route.id, directionId: 0),
            tripFilter: nil,
            setStopFilter: { _ in },
            setTripFilter: { _ in },
            tiles: [tile],
            noPredictionsStatus: nil,
            alerts: [alert],
            downstreamAlerts: [],
            patternsByStop: .init(route: route, stop: stop, patterns: [], elevatorAlerts: []),
            pinned: false,
            now: Date.now,
            errorBannerVM: .init(),
            nearbyVM: nearbyVM,
            mapVM: .init(),
            stopDetailsVM: .init()
        ).environmentObject(ViewportProvider())

        XCTAssertNotNil(try sut.inspect().find(DepartureTile.self))
        XCTAssertNotNil(try sut.inspect().find(AlertCard.self))
        XCTAssertNotNil(try sut.inspect().find(text: "Delays due to heavy ridership"))
    }
}
